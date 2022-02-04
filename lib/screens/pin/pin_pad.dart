import 'dart:async';
import 'dart:io';

import 'package:provenance_wallet/common/fw_design.dart';

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
                child: FwText(
                  widget.subTitle,
                  style: FwTextStyle.m,
                  textAlign: TextAlign.center,
                  color: FwColor.globalNeutral550,
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

  Widget _buildContainerCircle(BuildContext context, int number) {
    return InkResponse(
      highlightColor: Colors.red,
      onTap: () {
        _onCodeClick(number);
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
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
        children.add(_buildContainerCircle(context, _numbers[i]));
        children.add(_buildDeleteButton(context));
      } else {
        children.add(_buildContainerCircle(context, _numbers[i]));
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

  Widget _buildDeleteButton(BuildContext context) {
    return InkResponse(
      onTap: _deleteCode,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: _circleColor,
        ),
        child: Center(
          child: FwIcon(
            FwIcons.remove,
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
