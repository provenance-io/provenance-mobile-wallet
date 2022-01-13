import 'package:flutter/services.dart';
import 'package:flutter_tech_wallet/common/enum/wallet_add_import_type.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/common/widgets/modal_loading.dart';
import 'package:flutter_tech_wallet/screens/create_pin.dart';
import 'package:flutter_tech_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class RecoverPassphraseEntry extends StatefulWidget {
  RecoverPassphraseEntry(
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
    return RecoverPassphraseEntryState(
      flowType,
      accountName,
      currentStep: currentStep,
      numberOfSteps: numberOfSteps,
    );
  }
}

class RecoverPassphraseEntryState extends State<RecoverPassphraseEntry> {
  RecoverPassphraseEntryState(
    this.flowType,
    this.accountName, {
    this.currentStep,
    this.numberOfSteps,
  });

  final _formKey = GlobalKey<FormState>();

  final int? currentStep;
  final int? numberOfSteps;
  final String accountName;
  final WalletAddImportType flowType;
  List<TextEditingController> textControllers = <TextEditingController>[];
  List<FocusNode> focusNodes = <FocusNode>[];

  handlePaste(TextEditingController controller) {
    _pasteWords(controller);
  }

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < 24; i++) {
      var word = TextEditingController();
      addListener(word);
      this.textControllers.add(word);
      this.focusNodes.add(FocusNode());
    }
  }

  void addListener(TextEditingController controller) {
    controller.addListener(() {
      _handleTextControllerTextChange(controller);
    });
  }

  List<Widget> buildTextNodes(double width) {
    var first = List<Widget>.empty(growable: true);
    var second = List<Widget>.empty(growable: true);
    for (var i = 0; i <= 11; i++) {
      var text1 = _TextFormField(
        controller: textControllers.elementAt(i),
        number: '${i + 1}',
        focusNode: focusNodes.elementAt(i),
        handlePaste: handlePaste,
      );
      var text2 = _TextFormField(
        controller: textControllers.elementAt(i + 12),
        number: '${i + 13}',
        focusNode: focusNodes.elementAt(i + 12),
        handlePaste: handlePaste,
      );
      first.add(text1);
      second.add(text2);
      if (i != 12) {
        first.add(VerticalSpacer.small());
        second.add(VerticalSpacer.small());
      }
    }

    return [
      Container(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: first,
        ),
      ),
      Container(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: second,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: FwText(
                            Strings.enterYourRecoveryPassphrase,
                            style: FwTextStyle.extraLarge,
                            textAlign: TextAlign.left,
                            color: FwColor.globalNeutral550,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final width = (constraints.maxWidth - 20) / 2;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: buildTextNodes(width),
                      );
                    }),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: FwButton(
                      child: FwText(
                        Strings.recover,
                        style: FwTextStyle.mBold,
                        color: FwColor.white,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() == true) {
                          final words = this
                              .textControllers
                              .map((e) => e.text.trim())
                              .toList();

                          if (flowType ==
                              WalletAddImportType.onBoardingRecover) {
                            Navigator.of(context).push(CreatePin(
                              flowType,
                              accountName: accountName,
                              currentStep: (currentStep ?? 0) + 1,
                              numberOfSteps: numberOfSteps,
                              words: words,
                            ).route());
                          } else {
                            ModalLoadingRoute.showLoading(
                              Strings.pleaseWait,
                              context,
                            );
                            // TODO: What do we do with this?
                            // ignore: unused_local_variable
                            String privateKey =
                                await ProvWalletFlutter.getPrivateKey(
                              words.join(' '),
                            );
                            await ProvWalletFlutter.saveToWalletService(
                              words.join(' '),
                              accountName,
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
                  SizedBox(
                    height: 40,
                  ),
                  if (numberOfSteps != null)
                    ProgressStepper(
                      (currentStep ?? 0),
                      numberOfSteps ?? 1,
                      padding: EdgeInsets.only(left: 20, right: 20),
                    ),
                  if (numberOfSteps != null) VerticalSpacer.xxLarge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _handleTextControllerTextChange(TextEditingController controller) {
    String pastedText = controller.text;
    if (pastedText.length > 0) {
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
    for (var part in parts) {
      var index = parts.indexOf(part);
      textControllers[index].text = part;
    }
  }
}

class _TextFormField extends StatelessWidget {
  _TextFormField({
    Key? key,
    this.keyboardType,
    this.number,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.handlePaste,
    this.controller,
  }) : super(key: key);

  final String? number;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function? handlePaste;

  TextStyle _decorationStyleOf(BuildContext context) {
    final theme = Theme.of(context);

    return theme.textTheme.medium.copyWith(color: theme.hintColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        TextFormField(
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
          style: Theme.of(context)
              .textTheme
              .medium
              .copyWith(color: Theme.of(context).colorScheme.globalNeutral550),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            prefix: Container(
              width: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.midGrey),
            ),
          ),
        ),
        // GestureDetector(
        // behavior: HitTestBehavior.opaque,
        //   onTap: () {
        //     FocusScope.of(context).requestFocus(focusNode);
        //   },
        //     onTapDown: (details) {
        //       _storePosition(details);
        //     },
        //   onLongPress: () async {
        //     final result = await showMenu(context: context,
        //       position: RelativeRect.fromRect(
        //           (_tapPosition ?? Offset(0,0)) & Size(40, 40), // smaller rect, the touch area
        //           Offset.zero & overlay.size // Bigger rect, the entire screen
        //       ),
        //       items: [
        //         PopupMenuItem<bool>(
        //           value: true,
        //           child: FwText('Paste'),
        //         ),
        //       ],);
        //
        //     if (result == true) {
        //       handlePaste!(controller!);
        //     }
        //
        //   },
        //   child: IgnorePointer(
        //     child: TextFormField(
        //       keyboardType: keyboardType,
        //       autocorrect: false,
        //       controller: controller,
        //       onChanged: onChanged,
        //       focusNode: focusNode,
        //       autovalidateMode: AutovalidateMode.onUserInteraction,
        //       validator: (word) {
        //         if (word == null || word.isEmpty) {
        //           return "*required";
        //         }
        //
        //         return null;
        //       },
        //       style: Theme.of(context)
        //           .textTheme
        //           .medium
        //           .copyWith(color: Theme.of(context).colorScheme.globalNeutral550),
        //       decoration: InputDecoration(
        //         fillColor: Colors.white,
        //         filled: true,
        //         prefix: Container(
        //           width: 20,
        //         ),
        //         enabledBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: theme.colorScheme.midGrey),
        //         ),
        //       ),
        //     )
        //   )
        // ),
        Builder(builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HorizontalSpacer.small(),
                  Text(
                    number!,
                    style: _decorationStyleOf(context),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );

    return TextFormField(
      keyboardType: keyboardType,
      autocorrect: false,
      controller: controller,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      style: Theme.of(context)
          .textTheme
          .medium
          .copyWith(color: Theme.of(context).colorScheme.globalNeutral550),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        prefix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FwText(
              number!,
              style: FwTextStyle.m,
              color: FwColor.globalNeutral550,
            ),
            VerticalSpacer.large()
          ],
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.midGrey),
        ),
      ),
    );
  }
}
