import 'package:provenance_wallet/common/pw_design.dart';

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
  static const height = 16.0;
  static const width = 16.0;
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
            width: width,
            height: height,
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
            width: width,
            height: 3,
            child: Container(
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                border: new Border.all(
                  color: Theme.of(context).colorScheme.neutralNeutral,
                  width: 1.0,
                ),
                color: Theme.of(context).colorScheme.neutralNeutral,
              ),
            ),
          ));
        } else {
          circles.add(new SizedBox(
            width: width,
            height: height,
            child: new Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(
                  color: Theme.of(context).colorScheme.primaryP500,
                  width: 1.0,
                ),
                color: Theme.of(context).colorScheme.primaryP500,
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
            size: new Size(30.0 * codeLength, height),
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
