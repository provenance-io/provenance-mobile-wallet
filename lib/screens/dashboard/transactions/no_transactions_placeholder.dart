import 'package:provenance_wallet/common/fw_design.dart';
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
            children: [
              Expanded(
                child: FwText(
                  Strings.noTransactionsText,
                  color: FwColor.globalNeutral550,
                  style: FwTextStyle.h7,
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
