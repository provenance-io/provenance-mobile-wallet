import 'dart:async';
import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tech_wallet/common/enum/wallet_add_import_type.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/screens/confirm_pin.dart';
import 'package:flutter_tech_wallet/util/strings.dart';

class CreatePin extends StatefulHookWidget {
  CreatePin(
    this.flowType, {
    this.words,
    this.accountName,
    this.currentStep,
    this.numberOfSteps,
  });

  final List<String>? words;
  final String? accountName;
  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

  @override
  State<StatefulWidget> createState() {
    return CreatePinState();
  }
}

class CreatePinState extends State<CreatePin> {
  var _currentCodeLength = 0;
  var _inputCodes = <int>[];
  var _currentState = 0;
  Color circleColor = Colors.white;

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
      body: Container(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FwText(
                      Strings.setYourPinCode,
                      style: FwTextStyle.extraLarge,
                      textAlign: TextAlign.left,
                      color: FwColor.globalNeutral550,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: CodePanel(
                  codeLength: 6,
                  currentLength: _currentCodeLength,
                  status: _currentState,
                  deleteCode: _deleteCode,
                  borderColor: Theme.of(context).colorScheme.globalNeutral550,
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Expanded(
                flex: Platform.isIOS ? 5 : 6,
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 0),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();

                      return true;
                    },
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 1.6,
                      mainAxisSpacing: 35,
                      padding: EdgeInsets.all(8),
                      children: <Widget>[
                        buildContainerCircle(1),
                        buildContainerCircle(2),
                        buildContainerCircle(3),
                        buildContainerCircle(4),
                        buildContainerCircle(5),
                        buildContainerCircle(6),
                        buildContainerCircle(7),
                        buildContainerCircle(8),
                        buildContainerCircle(9),
                        // buildRemoveIcon(Icons.close),
                        Container(),
                        buildContainerCircle(0),
                        buildContainerIcon(Icons.arrow_back),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              SizedBox(
                height: 40,
              ),
              if (widget.numberOfSteps != null)
                ProgressStepper(
                  widget.currentStep ?? 0,
                  widget.numberOfSteps ?? 1,
                  padding: EdgeInsets.only(left: 20, right: 20),
                ),
              if (widget.numberOfSteps != null) VerticalSpacer.xxLarge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContainerCircle(int number) {
    return InkResponse(
      highlightColor: Colors.red,
      onTap: () {
        _onCodeClick(number);
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          // shape: BoxShape.circle,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 10,
          //     spreadRadius: 0,
          //   )
          // ]
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.globalNeutral550,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRemoveIcon(IconData icon) {
    return InkResponse(
      onTap: () {
        if (0 < _currentCodeLength) {
          _deleteAllCode();
        }
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          // shape: BoxShape.circle,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 10,
          //     spreadRadius: 0,
          //   )
          // ]
        ),
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
        ),
      ),
    );
  }

  Widget buildContainerIcon(IconData icon) {
    return InkResponse(
      onTap: () {
        if (0 < _currentCodeLength) {
          setState(() {
            circleColor = Colors.grey.shade300;
          });
          Future.delayed(Duration(milliseconds: 200)).then((func) {
            setState(() {
              circleColor = Colors.white;
            });
          });
        }
        _deleteCode();
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: circleColor,
          // shape: BoxShape.circle,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 10,
          //     spreadRadius: 0,
          //   )
          // ]
        ),
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
        ),
      ),
    );
  }

  _deleteCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength--;
        _inputCodes.removeAt(_currentCodeLength);
      }
    });
  }

  _deleteAllCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength = 0;
        _inputCodes.clear();
      }
    });
  }

  _onCodeClick(int code) {
    if (_currentCodeLength < 6) {
      setState(() {
        _currentCodeLength++;
        _inputCodes.add(code);
      });

      if (_currentCodeLength == 6) {
        Navigator.of(context).push(ConfirmPin(
          widget.flowType,
          accountName: widget.accountName,
          words: widget.words,
          code: _inputCodes,
          numberOfSteps: widget.numberOfSteps,
          currentStep: widget.currentStep,
        ).route());
      }
    }
  }
}

class _TextFormField extends StatelessWidget {
  const _TextFormField({
    Key? key,
    required this.label,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.controller,
  }) : super(key: key);

  final String label;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FwText(label),
        const VerticalSpacer.small(),
        TextFormField(
          keyboardType: keyboardType,
          autocorrect: false,
          controller: controller,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.midGrey),
            ),
          ),
        ),
      ],
    );
  }
}

typedef void DeleteCode();
typedef Future<bool> PassCodeVerify(List<int> passcode);
