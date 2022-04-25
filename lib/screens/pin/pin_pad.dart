import 'dart:io';

import 'package:provenance_blockchain_wallet/common/pw_design.dart';
import 'package:provenance_blockchain_wallet/screens/pin/code_panel.dart';
import 'package:provenance_blockchain_wallet/screens/pin/container_circle_button.dart';

Key keyPinPadNumber(int number) => ValueKey('$PinPad.number_$number');

double _clamp(
  double value,
  double min,
  double max,
) {
  if (value < min) {
    return min;
  } else if (value > max) {
    return max;
  } else {
    return value;
  }
}

class PinPad extends StatefulWidget {
  const PinPad({
    required this.onFinish,
    required this.subTitle,
    Key? key,
  }) : super(key: key);

  final Function onFinish;
  final String subTitle;

  @override
  State<StatefulWidget> createState() {
    return PinPadState();
  }
}

class PinPadState extends State<PinPad> {
  final _numbers = [
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
  final _inputCodes = <int>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: SizedBox(
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
    );
  }

  _deleteCode() {
    setState(() {
      if (_inputCodes.isNotEmpty) {
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
        final copy = List<int>.from(_inputCodes);

        widget.onFinish(copy);
        setState(() {
          _inputCodes.clear();
        });
      }
    }
  }

  Widget _buildGridView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = _clamp(
            constraints.maxHeight,
            220,
            480,
          );
          final availableWidth = _clamp(
            constraints.maxWidth,
            0,
            480,
          );

          const int columnCount = 3;
          final maxCrossExtent = availableWidth / columnCount;
          final maxMainExtent = availableHeight / 4;

          final ratio = maxCrossExtent / maxMainExtent;

          var children = <Widget>[];

          for (var i = 0; i < _numbers.length; i++) {
            if (i == _numbers.length - 1) {
              children.add(Container());

              children.add(ContainerCircleButton(
                key: keyPinPadNumber(_numbers[i]),
                child: PwText(
                  _numbers[i].toString(),
                  style: PwTextStyle.display1,
                ),
                onClick: () {
                  _onCodeClick(_numbers[i]);
                },
              ));
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
                key: keyPinPadNumber(_numbers[i]),
                child: PwText(
                  _numbers[i].toString(),
                  style: PwTextStyle.display1,
                ),
                onClick: () {
                  _onCodeClick(_numbers[i]);
                },
              ));
            }
          }

          return Center(
            child: SizedBox(
              height: availableHeight,
              width: availableWidth,
              child: GridView.count(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                clipBehavior: Clip.none,
                crossAxisCount: columnCount,
                childAspectRatio: ratio,
                padding: EdgeInsets.zero,
                children: children,
              ),
            ),
          );
        },
      ),
    );
  }
}
