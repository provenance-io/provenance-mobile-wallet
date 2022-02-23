import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

class NoTransactionsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Expanded(
                child: PwText(
                  Strings.noTransactionsText,
                  color: PwColor.neutral550,
                  style: PwTextStyle.h7,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
