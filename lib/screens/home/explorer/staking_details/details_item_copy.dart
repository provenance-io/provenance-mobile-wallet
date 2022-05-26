import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/strings.dart';

class DetailsItemCopy extends StatelessWidget {
  final String displayTitle;
  final String dataToCopy;
  final String snackBarTitle;

  const DetailsItemCopy({
    Key? key,
    required this.displayTitle,
    required this.dataToCopy,
    required this.snackBarTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailsItem(
      title: displayTitle,
      endChild: GestureDetector(
        onTap: () async {
          await Clipboard.setData(
            ClipboardData(
              text: dataToCopy,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                snackBarTitle,
              ),
              backgroundColor: Theme.of(context).colorScheme.neutral700,
            ),
          );
        },
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: Spacing.medium,
              ),
              child: PwText(
                dataToCopy.abbreviateAddress(),
                style: PwTextStyle.body,
              ),
            ),
            PwIcon(
              PwIcons.copy,
              color: Theme.of(context).colorScheme.neutralNeutral,
            ),
          ],
        ),
      ),
    );
  }
}
