import 'package:flutter/services.dart';
import 'package:flutter_tech_wallet/common/enum/wallet_add_import_type.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/common/widgets/modal_loading.dart';
import 'package:flutter_tech_wallet/screens/create_pin.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class RecoverPassphraseEntry extends StatefulWidget {
  final int? currentStep;
  final int? numberOfSteps;
  final String accountName;
  final WalletAddImportType flowType;

  RecoverPassphraseEntry(this.flowType, this.accountName, {this.currentStep, this.numberOfSteps});

  @override
  State<StatefulWidget> createState() {
    return RecoverPassphraseEntryState(flowType, accountName, currentStep: currentStep, numberOfSteps: numberOfSteps);
  }
}

class RecoverPassphraseEntryState extends State<RecoverPassphraseEntry> {
  final int? currentStep;
  final int? numberOfSteps;
  final String accountName;
  final WalletAddImportType flowType;

  RecoverPassphraseEntryState(this.flowType, this.accountName, {this.currentStep, this.numberOfSteps});

  final _formKey = GlobalKey<FormState>();
  final word1 = TextEditingController();
  final word2 = TextEditingController();
  final word3 = TextEditingController();
  final word4 = TextEditingController();
  final word5 = TextEditingController();
  final word6 = TextEditingController();
  final word7 = TextEditingController();
  final word8 = TextEditingController();
  final word9 = TextEditingController();
  final word10 = TextEditingController();
  final word11 = TextEditingController();
  final word12 = TextEditingController();
  final word13 = TextEditingController();
  final word14 = TextEditingController();
  final word15 = TextEditingController();
  final word16 = TextEditingController();
  final word17 = TextEditingController();
  final word18 = TextEditingController();
  final word19 = TextEditingController();
  final word20 = TextEditingController();
  final word21 = TextEditingController();
  final word22 = TextEditingController();
  final word23 = TextEditingController();
  final word24 = TextEditingController();
  // final word1 = useTextEditingController(text: 'begin');
  // final word2 = useTextEditingController(text: 'mushroom');
  // final word3 = useTextEditingController(text: 'stairs');
  // final word4 = useTextEditingController(text: 'orange');
  // final word5 = useTextEditingController(text: 'hurdle');
  // final word6 = useTextEditingController(text: 'brick');
  // final word7 = useTextEditingController(text: 'start');
  // final word8 = useTextEditingController(text: 'forward');
  // final word9 = useTextEditingController(text: 'lamp');
  // final word10 = useTextEditingController(text: 'tattoo');
  // final word11 = useTextEditingController(text: 'this');
  // final word12 = useTextEditingController(text: 'inch');
  // final word13 = useTextEditingController(text: 'fatigue');
  // final word14 = useTextEditingController(text: 'skull');
  // final word15 = useTextEditingController(text: 'joke');
  // final word16 = useTextEditingController(text: 'scrub');
  // final word17 = useTextEditingController(text: 'height');
  // final word18 = useTextEditingController(text: 'huge');
  // final word19 = useTextEditingController(text: 'heart');
  // final word20 = useTextEditingController(text: 'brown');
  // final word21 = useTextEditingController(text: 'buzz');
  // final word22 = useTextEditingController(text: 'private');
  // final word23 = useTextEditingController(text: 'famous');
  // final word24 = useTextEditingController(text: 'monster');

  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();
  final focusNode3 = FocusNode();
  final focusNode4 = FocusNode();
  final focusNode5 = FocusNode();
  final focusNode6 = FocusNode();
  final focusNode7 = FocusNode();
  final focusNode8 = FocusNode();
  final focusNode9 = FocusNode();
  final focusNode10 = FocusNode();
  final focusNode11 = FocusNode();
  final focusNode12 = FocusNode();
  final focusNode13 = FocusNode();
  final focusNode14 = FocusNode();
  final focusNode15 = FocusNode();
  final focusNode16 = FocusNode();
  final focusNode17 = FocusNode();
  final focusNode18 = FocusNode();
  final focusNode19 = FocusNode();
  final focusNode20 = FocusNode();
  final focusNode21 = FocusNode();
  final focusNode22 = FocusNode();
  final focusNode23 = FocusNode();
  final focusNode24 = FocusNode();

  handlePaste(TextEditingController controller) {
    _pasteWords(controller);
  }

  @override
  void initState() {
    super.initState();

    addListener(word1);
    addListener(word2);
    addListener(word3);
    addListener(word4);
    addListener(word5);
    addListener(word6);
    addListener(word7);
    addListener(word8);
    addListener(word9);
    addListener(word10);
    addListener(word11);
    addListener(word12);
    addListener(word13);
    addListener(word14);
    addListener(word15);
    addListener(word16);
    addListener(word17);
    addListener(word18);
    addListener(word19);
    addListener(word20);
    addListener(word21);
    addListener(word22);
    addListener(word23);
    addListener(word24);
  }

  void addListener(TextEditingController controller) {
    controller.addListener(() {
      _handleTextControllerTextChange(controller);
    });
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
                                    'Enter your recovery passphrase',
                                    style: FwTextStyle.extraLarge,
                                    textAlign: TextAlign.left,
                                    color: FwColor.globalNeutral550,
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  final width = (constraints.maxWidth - 20) / 2;
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          width: width,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _TextFormField(
                                                controller: word1,
                                                number: '1',
                                                focusNode: focusNode1,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word2,
                                                number: '2',
                                                focusNode: focusNode2,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word3,
                                                number: '3',
                                                focusNode: focusNode3,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word4,
                                                number: '4',
                                                focusNode: focusNode4,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word5,
                                                number: '5',
                                                focusNode: focusNode5,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word6,
                                                number: '6',
                                                focusNode: focusNode6,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word7,
                                                number: '7',
                                                focusNode: focusNode7,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word8,
                                                number: '8',
                                                focusNode: focusNode8,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word9,
                                                number: '9',
                                                focusNode: focusNode9,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word10,
                                                number: '10',
                                                focusNode: focusNode10,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word11,
                                                number: '11',
                                                focusNode: focusNode11,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word12,
                                                number: '12',
                                                focusNode: focusNode12,
                                                handlePaste: handlePaste,
                                              )
                                            ],
                                          )),
                                      Container(
                                          width: width,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _TextFormField(
                                                controller: word13,
                                                number: '13',
                                                focusNode: focusNode13,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word14,
                                                number: '14',
                                                focusNode: focusNode14,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word15,
                                                number: '15',
                                                focusNode: focusNode15,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word16,
                                                number: '16',
                                                focusNode: focusNode16,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word17,
                                                number: '17',
                                                focusNode: focusNode17,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word18,
                                                number: '18',
                                                focusNode: focusNode18,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word19,
                                                number: '19',
                                                focusNode: focusNode19,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word20,
                                                number: '20',
                                                focusNode: focusNode20,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word21,
                                                number: '21',
                                                focusNode: focusNode21,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word22,
                                                number: '22',
                                                focusNode: focusNode22,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word23,
                                                number: '23',
                                                focusNode: focusNode23,
                                                handlePaste: handlePaste,
                                              ),
                                              VerticalSpacer.small(),
                                              _TextFormField(
                                                controller: word24,
                                                number: '24',
                                                focusNode: focusNode24,
                                                handlePaste: handlePaste,
                                              )
                                            ],
                                          ))
                                    ],
                                  );
                                })),
                            SizedBox(
                              height: 24,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: FwButton(
                                    child: FwText(
                                      'Recover',
                                      style: FwTextStyle.mBold,
                                      color: FwColor.white,
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState?.validate() ==
                                          true) {
                                        final words = [
                                          word1.text.trim(),
                                          word2.text.trim(),
                                          word3.text.trim(),
                                          word4.text.trim(),
                                          word5.text.trim(),
                                          word6.text.trim(),
                                          word7.text.trim(),
                                          word8.text.trim(),
                                          word9.text.trim(),
                                          word10.text.trim(),
                                          word11.text.trim(),
                                          word12.text.trim(),
                                          word13.text.trim(),
                                          word14.text.trim(),
                                          word15.text.trim(),
                                          word16.text.trim(),
                                          word17.text.trim(),
                                          word18.text.trim(),
                                          word19.text.trim(),
                                          word20.text.trim(),
                                          word21.text.trim(),
                                          word22.text.trim(),
                                          word23.text.trim(),
                                          word24.text.trim()
                                        ];
                                        if (flowType == WalletAddImportType.onBoardingRecover) {
                                          Navigator.of(context).push(CreatePin(
                                            flowType,
                                            accountName: accountName,
                                            currentStep: (currentStep ?? 0) + 1,
                                            numberOfSteps: numberOfSteps,
                                            words: words,
                                          ).route());
                                        } else {
                                          ModalLoadingRoute.showLoading("Please Wait", context);
                                          String privateKey =
                                              await ProvWalletFlutter.getPrivateKey(
                                              words.join(' '));
                                          await ProvWalletFlutter.saveToWalletService(words.join(' '), accountName);
                                          ModalLoadingRoute.dismiss(context);

                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        }
                                      }
                                    })),
                            SizedBox(
                              height: 40,
                            ),
                            if (numberOfSteps != null) ProgressStepper((currentStep ?? 0), numberOfSteps ?? 1, padding: EdgeInsets.only(left: 20, right: 20)),
                            if (numberOfSteps != null) VerticalSpacer.xxLarge()
                          ],
                        ))))));
  }

  _handleTextControllerTextChange(TextEditingController controller) {
    String pastedText = controller.text;
    if (pastedText.length > 0) {
      List<String> parts = pastedText.split(' ');
      if (parts.length == 48) {
        parts.removeWhere((element) => element.startsWith("[0-9]"));
      }
      if (parts.length == 24) {
        word1.text = parts[0];
        word2.text = parts[1];
        word3.text = parts[2];
        word4.text = parts[3];
        word5.text = parts[4];
        word6.text = parts[5];
        word7.text = parts[6];
        word8.text = parts[7];
        word9.text = parts[8];
        word10.text = parts[9];
        word11.text = parts[10];
        word12.text = parts[11];
        word13.text = parts[12];
        word14.text = parts[13];
        word15.text = parts[14];
        word16.text = parts[15];
        word17.text = parts[16];
        word18.text = parts[17];
        word19.text = parts[18];
        word20.text = parts[19];
        word21.text = parts[20];
        word22.text = parts[21];
        word23.text = parts[22];
        word24.text = parts[23];
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
        word1.text = parts[0];
        word2.text = parts[1];
        word3.text = parts[2];
        word4.text = parts[3];
        word5.text = parts[4];
        word6.text = parts[5];
        word7.text = parts[6];
        word8.text = parts[7];
        word9.text = parts[8];
        word10.text = parts[9];
        word11.text = parts[10];
        word12.text = parts[11];
        word13.text = parts[12];
        word14.text = parts[13];
        word15.text = parts[14];
        word16.text = parts[15];
        word17.text = parts[16];
        word18.text = parts[17];
        word19.text = parts[18];
        word20.text = parts[19];
        word21.text = parts[20];
        word22.text = parts[21];
        word23.text = parts[22];
        word24.text = parts[23];
      }
    }
  }
}

class _TextFormField extends StatelessWidget {
  _TextFormField({Key? key,
    this.keyboardType,
    this.number,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.handlePaste,
    this.controller})
      : super(key: key);

  final String? number;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  Offset? _tapPosition = Offset(0, 0);
  final Function? handlePaste;

  TextStyle _decorationStyleOf(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.medium.copyWith(color: theme.hintColor);
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final RenderBox overlay = Overlay
        .of(context)
        ?.context
        .findRenderObject() as RenderBox;
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
              return "*required";
            }

            return null;
          },
          style: Theme
              .of(context)
              .textTheme
              .medium
              .copyWith(color: Theme
              .of(context)
              .colorScheme
              .globalNeutral550),
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
                  )
                ],
              )
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
      style: Theme
          .of(context)
          .textTheme
          .medium
          .copyWith(color: Theme
          .of(context)
          .colorScheme
          .globalNeutral550),
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
