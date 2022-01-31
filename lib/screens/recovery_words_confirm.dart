import 'dart:math';

import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/word_selector.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/pin/create_pin.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class RecoveryWordsConfirm extends StatefulWidget {
  RecoveryWordsConfirm(
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
    return RecoveryWordsConfirmState();
  }
}

class RecoveryWordsConfirmState extends State<RecoveryWordsConfirm> {
  bool _isResponsible = false;
  List<String?> _selectedWords = [
    null,
    null,
    null,
    null,
  ];

  final _random = new Random();
  List<List<String>> wordGroups = [];

  List<String> trueWords = [];
  List<int?> trueWordsIndex = [
    null,
    null,
    null,
    null,
  ];

  bool loading = true;

  int next(
    int min,
    int max,
  ) {
    return min + _random.nextInt(max - min);
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  List<String> getWordList(List<String>? words, String includedWord) {
    List<String> selectedWords = [includedWord];
    for (var i = 0; i < 2; i++) {
      selectedWords.add(words?[next(0, words.length)] ?? "");
    }

    return selectedWords;
  }

  void setup() {
    List<String>? localWords = widget.words?.toList(growable: true);

    for (var i = 0; i < 4; i++) {
      var index = next(0, (localWords?.length ?? 2) - 1);
      var trueWord = localWords?.removeAt(index) ?? "";
      var trueWordIndex = widget.words?.indexOf(trueWord);
      trueWordsIndex[i] = trueWordIndex;
      trueWords.add(trueWord);
      var wordGroup = getWordList(localWords, trueWord);
      wordGroup.shuffle();
      wordGroups.add(wordGroup);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: loading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.white,
          elevation: 0.0,
          title: FwText(
            Strings.verifyRecoveryPassphrase,
            style: FwTextStyle.h6,
            textAlign: TextAlign.center,
            color: FwColor.globalNeutral550,
          ),
          leading: IconButton(
            icon: FwIcon(
              FwIcons.back,
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
              _buildWordSelector(0),
              SizedBox(
                height: 40,
              ),
              _buildWordSelector(1),
              SizedBox(
                height: 40,
              ),
              _buildWordSelector(2),
              SizedBox(
                height: 40,
              ),
              _buildWordSelector(3),
              Expanded(
                child: Container(),
              ),
              Row(
                children: [
                  Checkbox(
                    fillColor: MaterialStateProperty.all((Color(0xFF949494))),
                    value: _isResponsible,
                    onChanged: (bool? value) {
                      setState(() {
                        _isResponsible = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: FwText(
                      Strings.iAmResponsibleForMyWalletText,
                      style: FwTextStyle.sBold,
                      color: FwColor.globalNeutral550,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: FwButton(
                  child: FwText(
                    Strings.next,
                    style: FwTextStyle.mBold,
                    color: FwColor.white,
                  ),
                  onPressed: () {
                    _validation();
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

  Widget _buildWordSelector(int index) {
    if (loading) {
      return Container();
    }

    var wordGroup = wordGroups[index];
    var trueWordIndex = trueWordsIndex[index];

    return wordGroup.isEmpty || (trueWordIndex == null || trueWordIndex == -1)
        ? Container()
        : Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: WordSelector(
              words: wordGroup,
              wordNumber: trueWordIndex + 1,
              onWordSelected: (word) {
                _selectedWords[index] = word;
              },
            ),
          );
  }

  void _validation() async {
    if (_selectedWords.any((element) => element == null)) {
      await showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.pleaseMakeASelection,
        ),
      );
    } else if (_selectedWords[0] != trueWords[0] ||
        _selectedWords[1] != trueWords[1] ||
        _selectedWords[2] != trueWords[2] ||
        _selectedWords[3] != trueWords[3]) {
      await showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.yourSelectionsDoNotMatch,
        ),
      );
    } else if (!_isResponsible) {
      await showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.youMustAgreeToTheWalletSeedphraseTerms,
        ),
      );
    } else {
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
        String privateKey = await ProvWalletFlutter.getPrivateKey(
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
