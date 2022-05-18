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
              children: Iterable<int>.generate(_bloc.wordsCount).toList().map(
                (index) {
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
                        inputAction: (_bloc.wordsCount - 1 != index)
                            ? TextInputAction.next
                            : TextInputAction.done,
                      ),
                      index != _bloc.wordsCount - 1
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

class _TextFormField extends StatelessWidget {
  const _TextFormField({
    Key? key,
    required this.index,
    this.inputAction = TextInputAction.done,
  }) : super(key: key);

  final int index;
  final TextInputAction inputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = get<RecoverPassphraseBloc>();

    return Autocomplete<String>(
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 10.0,
            shape: Border.all(color: theme.colorScheme.neutral250),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200, maxWidth: 335),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Container(
                      color: Theme.of(context).colorScheme.neutral700,
                      padding: const EdgeInsets.all(16.0),
                      child: PwText(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        return Mnemonic.searchFor(textEditingValue.text);
      },
      fieldViewBuilder: (context, controller, focusNode, func) {
        bloc.setFromIndex(index, controller);
        return TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          enableSuggestions: false,
          keyboardType: TextInputType.name,
          autocorrect: false,
          controller: controller,
          onChanged: (e) {
            final test = Mnemonic.searchFor(e);
            if (test.length == 1 && test.first == e) {
              func();
            }
          },
          onFieldSubmitted: (e) => func(),
          focusNode: focusNode,
          textInputAction: inputAction,
          validator: (word) {
            if (word == null || word.isEmpty) {
              return Strings.required;
            }
            if (!Mnemonic.searchFor(word).any((element) => element == word)) {
              return Strings.invalidWord;
            }

            return null;
          },
          style: Theme.of(context).textTheme.body,
          decoration: InputDecoration(
            fillColor: Theme.of(context).colorScheme.neutral750,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.neutral250),
            ),
          ),
        );
      },
    );
  }
}
