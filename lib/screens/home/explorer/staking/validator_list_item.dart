import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';

class ValidatorListItem extends StatelessWidget {
  const ValidatorListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  final ProvenanceValidator item;
  final textDivider = " • ";
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Navigate to delegate screen
      },
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: Spacing.largeX3,
                height: Spacing.largeX3,
                child: Image.network(
                  item.imgUrl ?? "",
                  errorBuilder: (context, error, stackTrace) {
                    // TODO: Build 'image' based on validator's first initial
                    return Container();
                  },
                ),
              ),
              HorizontalSpacer.medium(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwText(
                    item.moniker,
                    style: PwTextStyle.bodyBold,
                  ),
                  VerticalSpacer.xSmall(),
                  SizedBox(
                    width: 180,
                    child: PwText(
                      '${item.delegators} delegators$textDivider${item.commission} commission',
                      color: PwColor.neutral200,
                      style: PwTextStyle.footnote,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: PwIcon(
                  PwIcons.caret,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                  size: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}