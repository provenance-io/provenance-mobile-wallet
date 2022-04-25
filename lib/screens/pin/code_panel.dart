import 'package:provenance_blockchain_wallet/common/pw_design.dart';

typedef DeleteCode = void Function();
typedef PassCodeVerify = Future<bool> Function(List<int> passcode);

class CodePanel extends StatelessWidget {
  const CodePanel({
    required this.codeLength,
    required this.currentLength,
    required this.borderColor,
    this.foregroundColor,
    this.deleteCode,
    this.fingerVerify,
    this.status,
    Key? key,
  })  : assert(codeLength > 0),
        assert(currentLength >= 0),
        assert(currentLength <= codeLength),
        assert(deleteCode != null),
        assert(status == 0 || status == 1 || status == 2),
        super(key: key);

  final int codeLength;
  final int currentLength;
  final Color borderColor;
  final bool? fingerVerify;
  final Color? foregroundColor;
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
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.0),
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
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.neutralNeutral,
                  width: 1.0,
                ),
                color: Theme.of(context).colorScheme.neutralNeutral,
              ),
            ),
          ));
        } else {
          circles.add(SizedBox(
            width: width,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary500,
                  width: 1.0,
                ),
                color: Theme.of(context).colorScheme.primary500,
              ),
            ),
          ));
        }
      }
    }

    return SizedBox.fromSize(
      size: Size(MediaQuery.of(context).size.width, 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox.fromSize(
            size: Size(30.0 * codeLength, height),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: circles,
            ),
          ),
        ],
      ),
    );
  }
}
