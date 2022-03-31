import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/recovery_words/words_table.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_confirm_screen.dart';
import 'package:provenance_wallet/util/strings.dart';

class RecoveryWordsScreen extends StatefulWidget {
  const RecoveryWordsScreen(
    this.flowType,
    this.accountName, {
    this.currentStep,
    this.numberOfSteps,
    Key? key,
  }) : super(key: key);

  final int? currentStep;
  final int? numberOfSteps;
  final String accountName;
  final WalletAddImportType flowType;

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
        title: Strings.recoveryPassphrase,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(MediaQuery.of(context).size),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .neutralNeutral,
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
                      Navigator.of(context).push(RecoveryWordsConfirmScreen(
                        widget.flowType,
                        accountName: widget.accountName,
                        words: words,
                        currentStep: widget.currentStep ?? 0,
                        numberOfSteps: widget.numberOfSteps ?? 0,
                      ).route());
                    },
                  ),
                ),
                VerticalSpacer.largeX4(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
