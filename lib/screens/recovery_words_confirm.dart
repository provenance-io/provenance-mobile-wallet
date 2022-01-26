import 'dart:math';

import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/word_selector.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/create_pin.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

// ignore_for_file: prefer-trailing-comma
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
  String? _selectedWord1;
  String? _selectedWord2;
  String? _selectedWord3;
  String? _selectedWord4;

  final _random = new Random();

  List<String> wordGroup1 = [];
  List<String> wordGroup2 = [];
  List<String> wordGroup3 = [];
  List<String> wordGroup4 = [];

  int word1 = -1;
  int word2 = -1;
  int word3 = -1;
  int word4 = -1;

  bool loading = true;

  int next(
    int min,
    int max,
    Map<int, int> excluding,
  ) {
    int num = min + _random.nextInt(max - min);
    while (excluding.containsKey(num)) {
      num = min + _random.nextInt(max - min);
    }

    return num;
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  List<String> getWordList(
    int count,
    int max,
    int mustInclude,
  ) {
    int index = 0;
    List<String> words = [];
    Map<int, int> usedNumbers = {mustInclude: mustInclude};
    while (index < count - 1) {
      int num = next(
        1,
        max,
        usedNumbers,
      );
      usedNumbers[num] = num;
      words.add(widget.words?[num] ?? '');
      index++;
    }

    int insertIndex = next(0, count, {});
    if (insertIndex == count - 1) {
      words.add(widget.words?[mustInclude] ?? '');
    } else {
      words.insert(insertIndex, widget.words?[mustInclude] ?? '');
    }

    return words;
  }

  void setup() async {
    int max = (widget.words?.length ?? 2) - 1;
    Map<int, int> usedNumbers = {};

    word1 = next(0, max, {});
    usedNumbers[word1] = word1;
    word2 = next(0, max, usedNumbers);
    usedNumbers[word2] = word2;
    word3 = next(0, max, usedNumbers);
    usedNumbers[word3] = word3;
    word4 = next(0, max, usedNumbers);

    wordGroup1 = getWordList(3, max, word1);
    wordGroup2 = getWordList(3, max, word2);
    wordGroup3 = getWordList(3, max, word3);
    wordGroup4 = getWordList(3, max, word4);

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
          backgroundColor: Colors.white,
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
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: WordSelector(
                    words: wordGroup1,
                    wordNumber: word1 + 1,
                    onWordSelected: (word) {
                      _selectedWord1 = word;
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: WordSelector(
                    words: wordGroup2,
                    wordNumber: word2 + 1,
                    onWordSelected: (word) {
                      _selectedWord2 = word;
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: WordSelector(
                    words: wordGroup3,
                    wordNumber: word3 + 1,
                    onWordSelected: (word) {
                      _selectedWord3 = word;
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: WordSelector(
                    words: wordGroup4,
                    wordNumber: word4 + 1,
                    onWordSelected: (word) {
                      _selectedWord4 = word;
                    },
                  ),
                ),
                Expanded(
                  child: Container(),
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
                      _validateWordSelection();
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                if (widget.numberOfSteps != null)
                  ProgressStepper(
                    (widget.currentStep ?? 0),
                    widget.numberOfSteps ?? 1,
                    padding: EdgeInsets.only(left: 20, right: 20),
                  ),
                if (widget.numberOfSteps != null) VerticalSpacer.xxLarge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateWordSelection() async {
    if (_selectedWord1 == null ||
        _selectedWord2 == null ||
        _selectedWord3 == null ||
        _selectedWord4 == null) {
      await showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.pleaseMakeASelection,
        ),
      );
    } else if (_selectedWord1 != widget.words?[word1] ||
        _selectedWord2 != widget.words?[word2] ||
        _selectedWord3 != widget.words?[word3] ||
        _selectedWord4 != widget.words?[word4]) {
      await showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.yourSelectionsDoNotMatch,
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
