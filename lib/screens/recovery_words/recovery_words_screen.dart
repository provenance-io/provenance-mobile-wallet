import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/recovery_words/words_table.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class RecoveryWordsScreen extends StatefulWidget {
  const RecoveryWordsScreen({
    required this.currentStep,
    required this.totalSteps,
    Key? key,
  }) : super(key: key);

  final int currentStep;
  final int totalSteps;

  @override
  State<StatefulWidget> createState() {
    return RecoveryWordsScreenState();
  }
}

class RecoveryWordsScreenState extends State<RecoveryWordsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _bloc = get<AddAccountFlowBloc>();

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
        title: Strings.recoveryPassphrase,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          widget.currentStep,
          widget.totalSteps,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.neutral750,
      body: PwOnboardingScreen(
        children: [
          VerticalSpacer.largeX3(),
          Padding(
            padding: EdgeInsets.only(
              left: Spacing.xxLarge,
              right: Spacing.xxLarge,
            ),
            child: PwText(
              Strings.recordTheseWordsInTheCorrectOrder,
              style: PwTextStyle.body,
              textAlign: TextAlign.center,
            ),
          ),
          VerticalSpacer.xLarge(),
          Container(
            margin: EdgeInsets.only(
              left: Spacing.xxLarge,
              right: Spacing.xxLarge,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Theme.of(context).colorScheme.neutral700,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: Spacing.xxLarge,
                right: Spacing.xxLarge,
                top: Spacing.large,
                bottom: Spacing.large,
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
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: words.join(' '),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            Strings.passphraseCopied,
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
                        PwText(Strings.copyPassphrase),
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
                Strings.continueName,
                style: PwTextStyle.bodyBold,
                color: PwColor.neutralNeutral,
              ),
              onPressed: () {
                _bloc.submitRecoveryWords(words);
              },
            ),
          ),
          VerticalSpacer.largeX4(),
        ],
      ),
    );
  }
}
