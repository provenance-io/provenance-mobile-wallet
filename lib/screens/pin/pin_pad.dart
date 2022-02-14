import 'dart:async';
import 'dart:io';

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_theme.dart';
import 'package:provenance_wallet/screens/pin/container_circle.dart';
import 'package:provenance_wallet/screens/pin/delete_button.dart';

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
          SizedBox(
            height: 24,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: CodePanel(
              codeLength: 6,
              currentLength: _inputCodes.length,
              status: 0,
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

        children.add(ContainerCircle(
          number: _numbers[i],
          onCodeClick: _onCodeClick,
        ));
        children.add(DeleteButton(
          deleteNumber: _deleteCode,
        ));
      } else {
        children.add(ContainerCircle(
          number: _numbers[i],
          onCodeClick: _onCodeClick,
        ));
      }
    }

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.6,
      mainAxisSpacing: 35,
      padding: EdgeInsets.all(8),
      children: children,
    );
  }
}
