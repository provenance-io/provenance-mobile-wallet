import 'package:flutter/services.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar_gesture_detector.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/screens/pin/create_pin.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
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
  final WalletAddImportType flowType;

  @override
  State<StatefulWidget> createState() {
    return RecoverPassphraseEntryScreenState();
  }
}

class RecoverPassphraseEntryScreenState
    extends State<RecoverPassphraseEntryScreen> {
  final _keyValueService = get<KeyValueService>();
  late final TimedCounter _tapCounter;

  List<TextEditingController> textControllers = <TextEditingController>[];
  List<FocusNode> focusNodes = <FocusNode>[];
  List<VoidCallback> callbacks = <VoidCallback>[];

  @override
  void initState() {
    super.initState();

    _tapCounter = TimedCounter(onSuccess: _toggleAdvancedUI);

    for (var i = 0; i < 24; i++) {
      var word = TextEditingController();
      _addListener(word);
      textControllers.add(word);
      focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    _tapCounter.cancel();

    for (var i = 0; i < textControllers.length; i++) {
      var controller = textControllers[i];
      var callback = callbacks[i];
      controller.removeListener(callback);
      controller.dispose();
    }
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
        onTap: _tapCounter.increment,
        child: PwAppBar(
          title: Strings.enterRecoveryPassphrase,
          leadingIcon: PwIcons.back,
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressStepper(
            widget.currentStep,
            widget.numberOfSteps ?? 1,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 40,
            ),
          ),
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
                        style: PwTextStyle.body,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              itemBuilder: (context, index) {
                final textController = textControllers[index];
                final focusNode = focusNodes[index];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      controller: textController,
                      focusNode: focusNode,
                      handlePaste: _handlePaste,
                    ),
                    index != textControllers.length - 1
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Spacing.largeX4,
                            ),
                            child: PwButton(
                              child: PwText(
                                Strings.continueName,
                                style: PwTextStyle.bodyBold,
                              ),
                              onPressed: () async {
                                if (textControllers
                                    .every((e) => e.text.isNotEmpty)) {
                                  final words = textControllers
                                      .map((e) => e.text.trim())
                                      .toList();

                                  if (widget.flowType ==
                                      WalletAddImportType.onBoardingRecover) {
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

                                    await get<WalletService>().addWallet(
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
              separatorBuilder: (context, index) {
                return Container();
              },
              itemCount: textControllers.length,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
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

  void _addListener(TextEditingController controller) {
    void listen() {
      _handleTextControllerTextChange(controller);
    }

    controller.addListener(listen);
    callbacks.add(listen);
  }

  _handlePaste(TextEditingController controller) {
    _pasteWords(controller);
  }

  _handleTextControllerTextChange(TextEditingController controller) {
    String pastedText = controller.text;
    if (pastedText.isNotEmpty) {
      List<String> parts = pastedText.split(' ');
      if (parts.length == 48) {
        parts.removeWhere((element) => element.startsWith("[0-9]"));
      }
      if (parts.length == 24) {
        _putPartsInText(parts);
      }
    }
  }

  _pasteWords(TextEditingController controller) async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    String? pastedText = data?.text;
    if (pastedText != null) {
      List<String> parts = pastedText.split('\\s+');
      if (parts.length == 48) {
        parts.removeWhere((element) => element.startsWith("[0-9]"));
      }
      if (parts.length == 24) {
        _putPartsInText(parts);
      }
    }
  }

  _putPartsInText(List<String> parts) {
    for (var i = 0; i < parts.length && i < textControllers.length; i++) {
      textControllers[i].text = parts[i];
    }
  }
}

class _TextFormField extends StatelessWidget {
  const _TextFormField({
    Key? key,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.handlePaste,
    this.controller,
  }) : super(key: key);

  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function? handlePaste;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      keyboardType: keyboardType,
      autocorrect: false,
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (word) {
        if (word == null || word.isEmpty) {
          return Strings.required;
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
  }
}
