import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/enum/account_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar_gesture_detector.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/screens/pin/create_pin.dart';
import 'package:provenance_wallet/screens/recover_passphrase_entry_screen/recover_passphrase_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provenance_wallet/util/timed_counter.dart';

class RecoverPassphraseEntryScreen extends StatefulWidget {
  const RecoverPassphraseEntryScreen(
    this.flowType,
    this.accountName, {
    Key? key,
    required this.currentStep,
    this.numberOfSteps,
  }) : super(key: key);

  final int currentStep;
  final int? numberOfSteps;
  final String accountName;
  final AccountAddImportType flowType;

  static final keyContinueButton =
      ValueKey('$RecoverPassphraseEntryScreen.continue_button');

  static final keyAppBar = ValueKey('$RecoverPassphraseEntryScreen.app_bar');

  static final networkToggle =
      ValueKey('$RecoverPassphraseEntryScreen.network_toggle');

  static final networkName =
      ValueKey('$RecoverPassphraseEntryScreen.network_name');

  static final wordList = ValueKey('$RecoverPassphraseEntryScreen.word_list');

  static Key keyPassphraseWordTextField(int index) =>
      ValueKey('$RecoverPassphraseEntryScreen.word_$index');

  @override
  State<StatefulWidget> createState() {
    return RecoverPassphraseEntryScreenState();
  }
}

class RecoverPassphraseEntryScreenState
    extends State<RecoverPassphraseEntryScreen> {
  final _keyValueService = get<KeyValueService>();
  late final TimedCounter _tapCounter;
  late final RecoverPassphraseBloc _bloc;

  @visibleForTesting
  static const toggleAdvancedUICount = 10;

  @override
  void initState() {
    super.initState();
    _bloc = RecoverPassphraseBloc();
    get.registerSingleton<RecoverPassphraseBloc>(_bloc);

    _tapCounter = TimedCounter(
      onSuccess: _toggleAdvancedUI,
      requiredCount: toggleAdvancedUICount,
    );
  }

  @override
  void dispose() {
    get.unregister<RecoverPassphraseBloc>();
    _tapCounter.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultChainId =
        _keyValueService.stream<String>(PrefKey.defaultChainId);
    final showAdvancedUI =
        _keyValueService.stream<bool>(PrefKey.showAdvancedUI);

    return Scaffold(
      appBar: PwAppBarGestureDetector(
        key: RecoverPassphraseEntryScreen.keyAppBar,
        onTap: _tapCounter.increment,
        child: PwAppBar(
          title: Strings.enterRecoveryPassphrase,
          leadingIcon: PwIcons.back,
          bottom: ProgressStepper(
            widget.currentStep,
            widget.numberOfSteps ?? 1,
          ),
        ),
      ),
      body: PwOnboardingScreen(
        children: [
          StreamBuilder<KeyValueData<bool>>(
            initialData: showAdvancedUI.valueOrNull,
            stream: showAdvancedUI,
            builder: (context, snapshot) {
              final showAdvancedUI = snapshot.data?.data ?? false;
              if (!showAdvancedUI) {
                return Container();
              }

              return StreamBuilder<KeyValueData<String>>(
                initialData: defaultChainId.valueOrNull,
                stream: defaultChainId,
                builder: (context, snapshot) {
                  final chainId = snapshot.data?.data ?? ChainId.mainNet;
                  final coin = ChainId.toCoin(chainId);

                  return GestureDetector(
                    key: RecoverPassphraseEntryScreen.networkToggle,
                    onTap: () {
                      final newChainId = chainId == ChainId.mainNet
                          ? ChainId.testNet
                          : ChainId.mainNet;
                      _keyValueService.setString(
                        PrefKey.defaultChainId,
                        newChainId,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        top: Spacing.xLarge,
                        left: Spacing.xLarge,
                        bottom: Spacing.medium,
                      ),
                      child: PwText(
                        Strings.recoverPassphraseNetwork(coin.displayName),
                        key: RecoverPassphraseEntryScreen.networkName,
                        style: PwTextStyle.body,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Column(
              key: RecoverPassphraseEntryScreen.wordList,
              mainAxisSize: MainAxisSize.min,
              children: Iterable<int>.generate(24).toList().map(
                (index) {
                  final textController = _bloc.getControllerFromIndex(index);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VerticalSpacer.xxLarge(),
                      SizedBox(
                        height: 22,
                        child: Row(
                          children: [
                            PwText(
                              Strings.recoverPassphraseWord(index + 1),
                            ),
                          ],
                        ),
                      ),
                      VerticalSpacer.small(),
                      _TextFormField(
                        key: RecoverPassphraseEntryScreen
                            .keyPassphraseWordTextField(index),
                        index: index,
                        inputAction:
                            (_bloc.textControllers.last != textController)
                                ? TextInputAction.next
                                : TextInputAction.done,
                      ),
                      index != 23
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: Spacing.largeX4,
                              ),
                              child: PwButton(
                                key: RecoverPassphraseEntryScreen
                                    .keyContinueButton,
                                child: PwText(
                                  Strings.continueName,
                                  style: PwTextStyle.bodyBold,
                                ),
                                onPressed: () async {
                                  if (_bloc.isMnemonicComplete()) {
                                    final words = _bloc.getCompletedMnemonic();

                                    if (widget.flowType ==
                                        AccountAddImportType
                                            .onBoardingRecover) {
                                      Navigator.of(context).push(CreatePin(
                                        widget.flowType,
                                        accountName: widget.accountName,
                                        currentStep: widget.currentStep + 1,
                                        numberOfSteps: widget.numberOfSteps,
                                        words: words,
                                      ).route());
                                    } else {
                                      ModalLoadingRoute.showLoading(
                                        "",
                                        context,
                                      );

                                      final chainId =
                                          await _keyValueService.getString(
                                                PrefKey.defaultChainId,
                                              ) ??
                                              ChainId.defaultChainId;
                                      final coin = ChainId.toCoin(chainId);

                                      await get<AccountService>().addAccount(
                                        phrase: words,
                                        name: widget.accountName,
                                        coin: coin,
                                      );

                                      ModalLoadingRoute.dismiss(context);

                                      final steps = widget.currentStep;
                                      for (var i = steps; i >= 1; i--) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleAdvancedUI() async {
    final value =
        await _keyValueService.getBool(PrefKey.showAdvancedUI) ?? false;
    await _keyValueService.setBool(
      PrefKey.showAdvancedUI,
      !value,
    );
  }
}

class _TextFormField extends StatefulWidget {
  const _TextFormField({
    Key? key,
    required this.index,
    this.inputAction = TextInputAction.done,
  }) : super(key: key);

  final int index;
  final TextInputAction inputAction;

  @override
  State<StatefulWidget> createState() => _TextFormFieldState();
}

class _TextFormFieldState extends State<_TextFormField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = get<RecoverPassphraseBloc>();
    final controller = bloc.getControllerFromIndex(widget.index);
    final focusNode = bloc.getFocusNodeFromIndex(widget.index);

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: StreamBuilder<List<String>>(
        stream: bloc.getWordsForIndex(widget.index),
        builder: (context, snapshot) {
          var suggestions = snapshot.data ?? [];

          return SearchField(
            suggestions: suggestions
                .map((e) => SearchFieldListItem(e, item: e))
                .toList(),
            controller: controller,
            focusNode: focusNode,
            onSuggestionTap: (e) {
              setState(() {
                controller.text = e.item as String;
                bloc.clearWordsForIndex(widget.index);
              });
            },
            validator: (word) {
              if (word == null || word.isEmpty) {
                return Strings.required;
              }
              if (!Mnemonic.searchFor(word).any((element) => element == word)) {
                return Strings.invalidWord;
              }

              return null;
            },
            searchStyle: theme.textTheme.body,
            searchInputDecoration: InputDecoration(
              fillColor: Theme.of(context).colorScheme.neutral750,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.neutral250),
              ),
            ),
            suggestionsDecoration:
                BoxDecoration(color: Theme.of(context).colorScheme.neutral750),
            suggestionItemDecoration:
                BoxDecoration(color: Theme.of(context).colorScheme.neutral750),
            textInputAction: widget.inputAction,
          );
        },
      ),
    );
  }
}
