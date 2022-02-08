import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

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

  void generateWords() async {
    final phraseString = await ProvWalletFlutter.generatePhraseWords;
    words = phraseString.split(" ");
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
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.white,
          elevation: 0.0,
          title: PwText(
            Strings.recoveryPassphrase,
            style: PwTextStyle.h5,
            textAlign: TextAlign.left,
            color: PwColor.globalNeutral550,
          ),
          leading: IconButton(
            icon: PwIcon(
              PwIcons.back,
              size: 24,
              color: Theme.of(context).colorScheme.globalNeutral550,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          color: Theme.of(context).colorScheme.white,
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
              SizedBox(
                height: 56,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwText(
                  Strings.recordTheseWordsInTheCorrectOrder,
                  style: PwTextStyle.m,
                  textAlign: TextAlign.center,
                  color: PwColor.globalNeutral550,
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
                            runSpacing: 48.0,
                            spacing: 2.0,
                            children: [
                              ...words
                                  .mapIndexed(
                                    (index, e) => PwText('${index + 1}. $e'),
                                  )
                                  .toList(),
                              GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: words.join(' ')),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(Strings.passphraseCopied),
                                    ),
                                  );
                                },
                                child: PwIcon(
                                  PwIcons.copy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwButton(
                  child: PwText(
                    Strings.next,
                    style: PwTextStyle.mBold,
                    color: PwColor.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(RecoveryWordsConfirm(
                      widget.flowType,
                      accountName: widget.accountName,
                      words: words,
                      currentStep: widget.currentStep ?? 0,
                      numberOfSteps: widget.numberOfSteps ?? 0,
                    ).route());
                  },
                ),
              ),
              VerticalSpacer.xxLarge(),
              VerticalSpacer.xxLarge(),
            ],
          ),
        ),
      ),
    );
  }
}
