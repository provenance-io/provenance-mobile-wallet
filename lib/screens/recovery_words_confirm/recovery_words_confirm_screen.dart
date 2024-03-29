import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_check_box.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_bloc.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/word_selector.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class RecoveryWordsConfirmBloc {
  List<String> get recoveryWords;
  void submitRecoveryWordsConfirm();
}

class RecoveryWordsConfirmScreen extends StatefulWidget {
  const RecoveryWordsConfirmScreen({
    required RecoveryWordsConfirmBloc bloc,
    Key? key,
  })  : _bloc = bloc,
        super(key: key);

  final RecoveryWordsConfirmBloc _bloc;

  static ValueKey keyCheckbox =
      ValueKey("$RecoveryWordsConfirmScreen.checkbox");
  static ValueKey keyContinueButton =
      ValueKey("$RecoveryWordsConfirmScreen.continue_button");

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
    bloc.setup(widget._bloc.recoveryWords);

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
        title: Strings.of(context).verifyPassphrase,
        leadingIcon: PwIcons.back,
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
                      right: Spacing.large,
                      left: Spacing.large,
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
                horizontal: Spacing.large,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwCheckBox(
                    key: RecoveryWordsConfirmScreen.keyCheckbox,
                    selected: _isResponsible,
                    onSelect: (isChecked) {
                      setState(() {
                        _isResponsible = isChecked;
                      });
                    },
                  ),
                  HorizontalSpacer.large(),
                  Expanded(
                    child: PwText(
                      Strings.of(context).iAmResponsibleForMyAccountText,
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
                key: RecoveryWordsConfirmScreen.keyContinueButton,
                child: PwText(
                  Strings.of(context).continueName,
                  style: PwTextStyle.bodyBold,
                  color: PwColor.neutralNeutral,
                ),
                onPressed: () {
                  _validation(context);
                },
              ),
            ),
            VerticalSpacer.largeX4(),
          ],
        ),
      ),
    );
  }

  void _validation(BuildContext context) async {
    final selectedWords = bloc.selectedWords.value;
    final trueWords = bloc.trueWords.value;

    if (selectedWords.any((element) => element == null)) {
      setError(Strings.of(context).pleaseMakeASelection);
    } else if (selectedWords[0] != trueWords[0] ||
        selectedWords[1] != trueWords[1] ||
        selectedWords[2] != trueWords[2] ||
        selectedWords[3] != trueWords[3]) {
      setError(Strings.of(context).yourSelectionsDoNotMatch);
    } else if (!_isResponsible) {
      setError(Strings.of(context).youMustAgreeToThePassphraseTerms);
    } else {
      widget._bloc.submitRecoveryWordsConfirm();

      setError("");
    }
  }
}
