import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tech_wallet/common/enum/wallet_add_import_type.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/screens/recovery_words_confirm.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class RecoveryWords extends StatefulWidget {
  final int? currentStep;
  final int? numberOfSteps;
  final String accountName;
  final WalletAddImportType flowType;

  RecoveryWords(this.flowType, this.accountName, {this.currentStep, this.numberOfSteps});

  @override
  State<StatefulWidget> createState() {
    return RecoveryWordsState();
  }
}

class RecoveryWordsState extends State<RecoveryWords> {
  List<String> words = [];
  bool _loading = true;

  @override
  void initState() {
    generateWords();
    super.initState();
  }

  void generateWords() async {
    final phraseString = await ProvWalletFlutter.generatePhraseWords;
    words = phraseString.split(" ");
    setState(() {
      _loading = false;
    });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: _loading,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              leading: IconButton(
                icon: FwIcon(
                  FwIcons.back,
                  size: 24,
                  color: Color(0xFF3D4151),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Container(
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: FwText(
                            'Recovery passphrase',
                            style: FwTextStyle.extraLarge,
                            textAlign: TextAlign.center,
                            color: FwColor.globalNeutral550,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: FwText(
                            'Make sure to record these words in the correct order, using the corresponding numbers.',
                            style: FwTextStyle.m,
                            textAlign: TextAlign.center,
                            color: FwColor.globalNeutral550,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Container(
                                  color: Color(0xFFE9EEF9),
                                  child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Row(
                                        children: [
                                          Wrap(
                                            direction: Axis.vertical,
                                            runSpacing: 24.0,
                                            spacing: 2.0,
                                            children: [...words
                                                .mapIndexed((index, e) =>
                                                FwText('${index + 1}. $e'))
                                                .toList(), GestureDetector(
                                              onTap: () async {
                                                await Clipboard.setData(ClipboardData(text: words.join(' ')));
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Passphrase Copied')),
                                                );
                                              },
                                              child: FwIcon(
                                                FwIcons.copy,
                                              ),
                                            )
                                            ],
                                          )
                                        ],
                                      ))),
                            )),
                        SizedBox(
                          height: 100,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: FwButton(
                                child: FwText(
                                  'Next',
                                  style: FwTextStyle.mBold,
                                  color: FwColor.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(RecoveryWordsConfirm(
                                      widget.flowType,
                                      accountName: widget.accountName,
                                      words: words,
                                      currentStep: widget.currentStep ?? 0,
                                      numberOfSteps: widget.numberOfSteps ?? 0
                                  ).route());
                                })),
                        SizedBox(
                          height: 40,
                        ),
                        if (widget.numberOfSteps != null) ProgressStepper(
                            widget.currentStep ?? 0, widget.numberOfSteps ?? 1,
                            padding: EdgeInsets.only(left: 20, right: 20)),
                        if (widget.numberOfSteps != null) VerticalSpacer
                            .xxLarge()
                      ],
                    )))));
  }
}
