import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_confirm_screen.dart';
import 'package:provenance_wallet/util/strings.dart';

class RecoveryWords extends StatefulWidget {
  RecoveryWords(
    this.flowType,
    this.accountName, {
    this.currentStep,
    this.numberOfSteps,
  });

  final int? currentStep;
  final int? numberOfSteps;
  final String accountName;
  final WalletAddImportType flowType;

  @override
  State<StatefulWidget> createState() {
    return RecoveryWordsState();
  }
}

class RecoveryWordsState extends State<RecoveryWords> {
  bool _loading = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> words = [];

  @override
  void initState() {
    generateWords();
    super.initState();
  }

  void generateWords() {
    words = Mnemonic.random(MnemonicStrength.high).toList();

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PwAppBar(
          title: Strings.recoveryPassphrase,
          leadingIcon: PwIcons.back,
        ),
        body: Container(
          color: Theme.of(context).colorScheme.provenanceNeutral750,
          child: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
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
                      Padding(
                        padding: EdgeInsets.only(
                          left: Spacing.largeX4,
                          right: Spacing.largeX4,
                        ),
                        child: PwText(
                          Strings.recordTheseWordsInTheCorrectOrder,
                          style: PwTextStyle.body,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      VerticalSpacer.xLarge(),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: Spacing.xxLarge,
                            right: Spacing.xxLarge,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              color: Theme.of(context)
                                  .colorScheme
                                  .provenanceNeutral700,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: Spacing.xxLarge,
                                right: Spacing.xxLarge,
                                top: Spacing.large,
                                bottom: Spacing.large,
                              ),
                              child: Wrap(
                                direction: Axis.vertical,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                //runSpacing: Spacing.small,
                                spacing: Spacing.medium,
                                children: [
                                  ...words
                                      .mapIndexed(
                                        (index, e) => SizedBox(
                                          width: 122,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  right: Spacing.small,
                                                ),
                                                child: PwText(
                                                  '${index + 1}',
                                                  style: PwTextStyle.body,
                                                  color: PwColor.neutral250,
                                                ),
                                              ),
                                              PwText(
                                                e,
                                                style: PwTextStyle.body,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      VerticalSpacer.large(),
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
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .provenanceNeutral700,
                            ),
                          );
                        },
                        child: PwIcon(
                          PwIcons.copy,
                          color: Theme.of(context).colorScheme.white,
                        ),
                      ),
                      VerticalSpacer.large(),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: PwButton(
                          child: PwText(
                            Strings.continueName,
                            style: PwTextStyle.bodyBold,
                            color: PwColor.white,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .push(RecoveryWordsConfirmScreen(
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
              );
            },
          ),
        ),
      ),
    );
  }
}
