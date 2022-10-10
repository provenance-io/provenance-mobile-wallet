import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/recovery_words/words_table.dart';
import 'package:provenance_wallet/util/strings.dart';

class RecoveryWordsScreen extends StatefulWidget {
  const RecoveryWordsScreen({
    required this.bloc,
    required this.currentStep,
    required this.totalSteps,
    Key? key,
  }) : super(key: key);

  final AddAccountFlowBloc bloc;
  final int currentStep;
  final int totalSteps;

  static final keyCopyButton = ValueKey("$RecoveryWordsScreen.copy_button");
  static final keySnackbar = ValueKey("$RecoveryWordsScreen.snackbar");
  static final keyContinueButton =
      ValueKey("$RecoveryWordsScreen.continue_button");

  @override
  State<StatefulWidget> createState() {
    return RecoveryWordsScreenState();
  }
}

class RecoveryWordsScreenState extends State<RecoveryWordsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> words = [];

  @override
  void initState() {
    generateWords();
    super.initState();
  }

  void generateWords() {
    words = Mnemonic.random(MnemonicStrength.high).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PwAppBar(
        title: Strings.of(context).recoveryPassphrase,
        leadingIcon: PwIcons.back,
      ),
      backgroundColor: Theme.of(context).colorScheme.neutral750,
      body: PwOnboardingScreen(
        children: [
          VerticalSpacer.largeX3(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.large,
            ),
            child: PwText(
              Strings.of(context).recordTheseWordsInTheCorrectOrder,
              style: PwTextStyle.body,
              textAlign: TextAlign.center,
            ),
          ),
          VerticalSpacer.xLarge(),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: Spacing.large,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Theme.of(context).colorScheme.neutral700,
            ),
            child: Padding(
              padding: EdgeInsets.all(
                Spacing.large,
              ),
              child: Column(
                children: [
                  WordsTable(
                    words: words,
                  ),
                  VerticalSpacer.xLarge(),
                  PwListDivider(),
                  VerticalSpacer.xLarge(),
                  GestureDetector(
                    key: RecoveryWordsScreen.keyCopyButton,
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: words.join(' '),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          key: RecoveryWordsScreen.keySnackbar,
                          content: Text(
                            Strings.of(context).passphraseCopied,
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.neutral700,
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: Spacing.medium,
                          ),
                          child: PwIcon(
                            PwIcons.copy,
                            color: Theme.of(context).colorScheme.neutralNeutral,
                          ),
                        ),
                        PwText(Strings.of(context).copyPassphrase),
                      ],
                    ),
                  ),
                  VerticalSpacer.xLarge(),
                ],
              ),
            ),
          ),
          Expanded(child: Container()),
          VerticalSpacer.xLarge(),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: PwButton(
              child: PwText(
                Strings.of(context).continueName,
                key: RecoveryWordsScreen.keyContinueButton,
                style: PwTextStyle.bodyBold,
                color: PwColor.neutralNeutral,
              ),
              onPressed: () {
                widget.bloc.submitRecoveryWords(words);
              },
            ),
          ),
          VerticalSpacer.largeX4(),
        ],
      ),
    );
  }
}
