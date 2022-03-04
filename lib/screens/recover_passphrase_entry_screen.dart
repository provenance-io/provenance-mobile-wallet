import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/pin/create_pin.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class RecoverPassphraseEntryScreen extends StatefulWidget {
  const RecoverPassphraseEntryScreen(
    this.flowType,
    this.accountName, {
    Key? key,
    this.currentStep,
    this.numberOfSteps,
  }) : super(key: key);

  final int? currentStep;
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
  List<TextEditingController> textControllers = <TextEditingController>[];
  List<FocusNode> focusNodes = <FocusNode>[];
  List<VoidCallback> callbacks = <VoidCallback>[];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < 24; i++) {
      var word = TextEditingController();
      _addListener(word);
      textControllers.add(word);
      focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.enterRecoveryPassphrase,
        leadingIcon: PwIcons.back,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProgressStepper(
            (widget.currentStep ?? 0),
            widget.numberOfSteps ?? 1,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 40,
            ),
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
                            "Passphrase ${index + 1}",
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
                                      currentStep:
                                          (widget.currentStep ?? 0) + 1,
                                      numberOfSteps: widget.numberOfSteps,
                                      words: words,
                                    ).route());
                                  } else {
                                    ModalLoadingRoute.showLoading(
                                      Strings.pleaseWait,
                                      context,
                                    );

                                    await get<WalletService>().addWallet(
                                      phrase: words,
                                      name: widget.accountName,
                                    );

                                    ModalLoadingRoute.dismiss(context);

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
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
