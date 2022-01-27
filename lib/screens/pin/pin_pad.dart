import 'dart:async';
import 'dart:io';

import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

class PinPad extends StatefulWidget {
  PinPad({
    required this.onFinish,
    required this.isConfirming,
  });

  final Function onFinish;
  final bool isConfirming;

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
  var _currentCodeLength = 0;
  var _inputCodes = <int>[];
  Color _circleColor = Colors.white;


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 48,
                  child: FwText(
                    Strings.setAPinCodeToUnlockYourWallet,
                    style: FwTextStyle.mBold,
                    textAlign: TextAlign.center,
                    color: FwColor.globalNeutral550,
                  ),
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
                child: _buildGridView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerCircle(int number) {
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

  _deleteCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentCodeLength--;
        _inputCodes.removeAt(_currentCodeLength);
      }
    });
  }

  _onCodeClick(int code) async {
    if (_currentCodeLength < 6) {
      setState(() {
        _currentCodeLength++;
        _inputCodes.add(code);
      });

      if (_currentCodeLength == 6) {
        widget.onFinish();
      }
    }
  }

  Widget _buildGridView() {
    var children = <Widget>[];

    for (var i = 0; i < _numbers.length; i++) {
      if (i == _numbers.length - 1) {
        children.add(Container());
        children.add(_buildContainerCircle(_numbers[i]));
        children.add(_buildDeleteButton());
      } else {
        children.add(_buildContainerCircle(_numbers[i]));
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

  Widget _buildDeleteButton() {
    return InkResponse(
      onTap: () {
        if (0 < _currentCodeLength) {
          setState(() {
            _circleColor = Colors.grey.shade300;
          });
          Future.delayed(Duration(milliseconds: 200)).then((func) {
            setState(() {
              _circleColor = Colors.white;
            });
          });
        }
        _deleteCode();
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: _circleColor,
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back,
            size: 30,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
        ),
      ),
    );
  }
}

typedef void DeleteCode();
typedef Future<bool> PassCodeVerify(List<int> passcode);

class CodePanel extends StatelessWidget {
  CodePanel({
    this.codeLength,
    this.currentLength,
    this.borderColor,
    this.foregroundColor,
    this.deleteCode,
    this.fingerVerify,
    this.status,
  })  : assert(codeLength > 0),
        assert(currentLength >= 0),
        assert(currentLength <= codeLength),
        assert(deleteCode != null),
        assert(status == 0 || status == 1 || status == 2);

  final codeLength;
  final currentLength;
  final borderColor;
  final bool? fingerVerify;
  final foregroundColor;
  final H = 16.0;
  final W = 16.0;
  final DeleteCode? deleteCode;
  final int? status;

  @override
  Widget build(BuildContext context) {
    var circles = <Widget>[];
    var color = borderColor;
    int circlePice = 1;

    if (fingerVerify == true) {
      do {
        circles.add(
          SizedBox(
            width: W,
            height: H,
            child: new Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(color: color, width: 1.0),
                color: Colors.green.shade500,
              ),
            ),
          ),
        );
        circlePice++;
      } while (circlePice <= codeLength);
    } else {
      if (status == 1) {
        color = Colors.green.shade500;
      }
      if (status == 2) {
        color = Colors.red.shade500;
      }
      for (int i = 1; i <= codeLength; i++) {
        if (i > currentLength) {
          circles.add(SizedBox(
            width: W,
            height: H,
            child: Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(color: color, width: 1.0),
                color: foregroundColor,
              ),
            ),
          ));
        } else {
          circles.add(new SizedBox(
            width: W,
            height: H,
            child: new Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(color: color, width: 1.0),
                color: color,
              ),
            ),
          ));
        }
      }
    }

    return new SizedBox.fromSize(
      size: new Size(MediaQuery.of(context).size.width, 30.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox.fromSize(
            size: new Size(30.0 * codeLength, H),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: circles,
            ),
          ),
        ],
      ),
    );
  }
}
