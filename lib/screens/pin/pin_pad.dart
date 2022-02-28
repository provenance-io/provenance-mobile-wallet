import 'dart:io';

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/pin/code_panel.dart';
import 'package:provenance_wallet/screens/pin/container_circle_button.dart';

class PinPad extends StatefulWidget {
  PinPad({
    required this.onFinish,
    required this.isConfirming,
    required this.subTitle,
  });

  final Function onFinish;
  final bool isConfirming;
  final String subTitle;

  @override
  State<StatefulWidget> createState() {
    return PinPadState();
  }
}

class PinPadState extends State<PinPad> {
  var _numbers = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    0,
  ];
  var _inputCodes = <int>[];
  Color _circleColor = Colors.white;

  @override
  void initState() {
    if (widget.isConfirming) {
      setState(() {
        _numbers.shuffle();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Container(
              height: 48,
              child: Center(
                child: PwText(
                  widget.subTitle,
                  style: PwTextStyle.body,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          VerticalSpacer.largeX6(),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: CodePanel(
              codeLength: 6,
              currentLength: _inputCodes.length,
              status: 0,
              deleteCode: _deleteCode,
              borderColor: Theme.of(context).colorScheme.neutralNeutral,
            ),
          ),
          VerticalSpacer.xxLarge(),
          Expanded(
            flex: Platform.isIOS ? 5 : 6,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 0,
              ),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();

                  return true;
                },
                child: _buildGridView(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _deleteCode() {
    setState(() {
      if (_inputCodes.length > 0) {
        _inputCodes.removeLast();
      }
    });
  }

  _onCodeClick(int code) async {
    if (_inputCodes.length < 6) {
      setState(() {
        _inputCodes.add(code);
      });

      if (_inputCodes.length == 6) {
        widget.onFinish(this._inputCodes);
      }
    }
  }

  Widget _buildGridView(BuildContext context) {
    var children = <Widget>[];

    for (var i = 0; i < _numbers.length; i++) {
      if (i == _numbers.length - 1) {
        children.add(Container());

        children.add(ContainerCircleButton(
          child: PwText(
            _numbers[i].toString(),
            style: PwTextStyle.display2,
          ),
          onClick: () {
            _onCodeClick(_numbers[i]);
          },
        ));
        //children.add(Container());
        children.add(ContainerCircleButton(
          child: PwIcon(
            PwIcons.remove,
            size: 22,
            color: Theme.of(context).colorScheme.neutralNeutral,
          ),
          onClick: _deleteCode,
        ));
      } else {
        children.add(ContainerCircleButton(
          child: PwText(
            _numbers[i].toString(),
            style: PwTextStyle.display2,
          ),
          onClick: () {
            _onCodeClick(_numbers[i]);
          },
        ));
      }
    }

    return GridView.count(
      clipBehavior: Clip.none,
      crossAxisCount: 3,
      childAspectRatio: 1.6,
      mainAxisSpacing: 35,
      padding: EdgeInsets.all(8),
      children: children,
    );
  }
}
