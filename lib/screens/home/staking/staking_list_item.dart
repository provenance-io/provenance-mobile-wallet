import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/staking/pw_avatar.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/extensions/string_extensions.dart';
import 'package:provenance_wallet/util/validator_util.dart';

class StakingListItem extends StatelessWidget {
  const StakingListItem({
    Key? key,
    required this.validator,
    required this.listItemText,
    required this.onTouch,
  }) : super(key: key);

  final ProvenanceValidator validator;
  final String listItemText;
  final Future<void> Function() onTouch;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await onTouch();
      },
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.all(Spacing.large),
          color: Theme.of(context).colorScheme.neutral700,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PwAvatar(
                initial: validator.moniker.substring(0, 1),
                imgUrl: validator.imgUrl ?? "",
              ),
              HorizontalSpacer.medium(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwText(
                    validator.moniker,
                    style: PwTextStyle.body,
                  ),
                  VerticalSpacer.xSmall(),
                  PwText(
                    listItemText,
                    color: PwColor.neutral200,
                    style: PwTextStyle.footnote,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  VerticalSpacer.xSmall(),
                  Row(
                    children: [
                      Icon(
                        Icons.brightness_1,
                        color:
                            validatorColorForStatus(context, validator.status),
                        size: 8,
                      ),
                      HorizontalSpacer.xSmall(),
                      PwText(
                        validator.status.name.capitalize(),
                        color: PwColor.neutral200,
                        style: PwTextStyle.footnote,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      )
                    ],
                  )
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
