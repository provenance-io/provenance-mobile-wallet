import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_check_box.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_bloc.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/word_selector.dart';
import 'package:provenance_wallet/util/strings.dart';

class RecoveryWordsConfirmScreen extends StatefulWidget {
  const RecoveryWordsConfirmScreen({
    required this.addAccountBloc,
    required this.currentStep,
    required this.totalSteps,
    Key? key,
  }) : super(key: key);

  final AddAccountFlowBloc addAccountBloc;
  final int currentStep;
  final int totalSteps;

  @override
  State<StatefulWidget> createState() {
    return RecoveryWordsConfirmScreenState();
  }
}

class RecoveryWordsConfirmScreenState
    extends State<RecoveryWordsConfirmScreen> {
  bool _isResponsible = false;
  String _error = "";

  final bloc = RecoveryWordsBloc();

  @override
  void initState() {
    bloc.setup(widget.addAccountBloc.words);

    super.initState();
  }

  @override
  void dispose() {
    bloc.onDispose();

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
        bottom: ProgressStepper(
          widget.currentStep,
          widget.totalSteps,
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: PwOnboardingScreen(
          children: [
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
            WordSelector(
              bloc: bloc,
              index: 0,
            ),
            VerticalSpacer.xLarge(),
            WordSelector(
              bloc: bloc,
              index: 1,
            ),
            VerticalSpacer.xLarge(),
            WordSelector(
              bloc: bloc,
              index: 2,
            ),
            VerticalSpacer.xLarge(),
            WordSelector(
              bloc: bloc,
              index: 3,
            ),
            VerticalSpacer.largeX3(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xxLarge,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwCheckBox(
                    onSelect: (isChecked) {
                      setState(() {
                        _isResponsible = isChecked;
                      });
                    },
                  ),
                  HorizontalSpacer.large(),
                  Expanded(
                    child: PwText(
                      Strings.iAmResponsibleForMyAccountText,
                      style: PwTextStyle.body,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwButton(
                child: PwText(
                  Strings.continueName,
                  style: PwTextStyle.bodyBold,
                  color: PwColor.neutralNeutral,
                ),
                onPressed: () {
                  _validation();
                },
              ),
            ),
            VerticalSpacer.largeX4(),
          ],
        ),
      ),
    );
  }

  void _validation() async {
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
      setError(Strings.youMustAgreeToThePassphraseTerms);
    } else {
      widget.addAccountBloc.submitRecoveryWordsConfirm();

      setError("");
    }
  }
}
