import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_theme.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_bloc.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/word_selector.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/pin/create_pin.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class RecoveryWordsConfirmScreen extends StatefulWidget {
  RecoveryWordsConfirmScreen(
    this.flowType, {
    @required this.words,
    this.accountName,
    this.currentStep,
    this.numberOfSteps,
  });

  final List<String>? words;
  final int? currentStep;
  final int? numberOfSteps;
  final String? accountName;
  final WalletAddImportType flowType;

  @override
  State<StatefulWidget> createState() {
    return RecoveryWordsConfirmScreenState();
  }
}

class RecoveryWordsConfirmScreenState
    extends State<RecoveryWordsConfirmScreen> {
  bool _isResponsible = false;
  String _error = "";

  @override
  void initState() {
    get.registerSingleton<RecoveryWordsBloc>(RecoveryWordsBloc());
    get<RecoveryWordsBloc>().setup(widget.words);
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<RecoveryWordsBloc>();
    super.dispose();
  }

  void setError(String error) {
    setState(() {
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.verifyPassphrase,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.provenanceNeutral750,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: viewportConstraints,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProgressStepper(
                      widget.currentStep ?? 0,
                      widget.numberOfSteps ?? 1,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,
                      ),
                    ),
                    VerticalSpacer.largeX3(),
                    _error.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(
                              bottom: Spacing.xLarge,
                              right: Spacing.xxLarge,
                              left: Spacing.xxLarge,
                            ),
                            child: PwText(
                              _error,
                              style: PwTextStyle.body,
                              color: PwColor.error,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container(),
                    WordSelector(index: 0),
                    VerticalSpacer.xLarge(),
                    WordSelector(index: 1),
                    VerticalSpacer.xLarge(),
                    WordSelector(index: 2),
                    VerticalSpacer.xLarge(),
                    WordSelector(index: 3),
                    VerticalSpacer.largeX3(),
                    Row(
                      children: [
                        Checkbox(
                          fillColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.primaryP500,
                          ),
                          value: _isResponsible,
                          onChanged: (bool? value) {
                            setState(() {
                              _isResponsible = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: PwText(
                            Strings.iAmResponsibleForMyWalletText,
                            style: PwTextStyle.body,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: PwButton(
                        child: PwText(
                          Strings.continueName,
                          style: PwTextStyle.mBold,
                          color: PwColor.white,
                        ),
                        onPressed: () {
                          _validation();
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _validation() async {
    final bloc = get<RecoveryWordsBloc>();
    final selectedWords = bloc.selectedWords.value;
    final trueWords = bloc.trueWords.value;

    if (selectedWords.any((element) => element == null)) {
      setError(Strings.pleaseMakeASelection);
    } else if (selectedWords[0] != trueWords[0] ||
        selectedWords[1] != trueWords[1] ||
        selectedWords[2] != trueWords[2] ||
        selectedWords[3] != trueWords[3]) {
      setError(Strings.yourSelectionsDoNotMatch);
    } else if (!_isResponsible) {
      setError(Strings.youMustAgreeToTheWalletSeedphraseTerms);
    } else {
      setError("");
      if (widget.flowType == WalletAddImportType.onBoardingAdd) {
        Navigator.of(context).push(CreatePin(
          widget.flowType,
          words: widget.words,
          accountName: widget.accountName,
          currentStep: (widget.currentStep ?? 0) + 1,
          numberOfSteps: widget.numberOfSteps,
        ).route());
      } else if (widget.flowType == WalletAddImportType.dashboardAdd) {
        ModalLoadingRoute.showLoading(Strings.pleaseWait, context);
        await ProvWalletFlutter.getPrivateKey(
          widget.words?.join(' ') ?? '',
        );
        await ProvWalletFlutter.saveToWalletService(
          widget.words?.join(' ') ?? '',
          widget.accountName ?? '',
        );
        ModalLoadingRoute.dismiss(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }
}
