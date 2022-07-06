import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/staking/pw_avatar.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class ValidatorCard extends StatefulWidget {
  const ValidatorCard({
    Key? key,
    this.moniker,
    this.imgUrl,
    this.description,
  }) : super(key: key);
  final String? moniker;
  final String? imgUrl;
  final String? description;

  bool get hasValidator {
    return (moniker?.isNotEmpty ?? false) ||
        (imgUrl?.isNotEmpty ?? false) ||
        (description?.isNotEmpty ?? false);
  }

  @override
  State<ValidatorCard> createState() => _ValidatorCardState();
}

class _ValidatorCardState extends State<ValidatorCard> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.hasValidator
          ? EdgeInsets.all(20)
          : EdgeInsets.symmetric(
              horizontal: Spacing.large, vertical: Spacing.xxLarge),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.neutral700,
        ),
        borderRadius: BorderRadius.circular(4),
        color: widget.hasValidator
            ? Theme.of(context).colorScheme.neutral700
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: !widget.hasValidator
            ? [
                PwText(
                  Strings.stakingRedelegateValidatorNotSelected,
                  style: PwTextStyle.footnote,
                  color: PwColor.neutral200,
                )
              ]
            : [
                Padding(
                  padding: EdgeInsets.only(top: Spacing.medium),
                  child: PwAvatar(
                    initial: widget.moniker!.substring(0, 1),
                    imgUrl: widget.imgUrl ?? "",
                  ),
                ),
                HorizontalSpacer.medium(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: PwText(
                              widget.moniker ?? "",
                              style: PwTextStyle.body,
                              color: PwColor.neutralNeutral,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                      if (widget.description != null &&
                          widget.description!.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(
                            top: Spacing.xSmall,
                          ),
                          child: PwText(
                            widget.description ?? "",
                            textAlign: TextAlign.left,
                            style: PwTextStyle.footnote,
                            color: PwColor.neutral200,
                            overflow: TextOverflow.fade,
                            maxLines: 20,
                            softWrap: _isActive,
                          ),
                        ),
                      HorizontalSpacer.xSmall(),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _isActive = !_isActive;
                          });
                        },
                        child: PwText(
                          _isActive
                              ? Strings.stakingDetailsViewLess
                              : Strings.viewMore,
                          color: PwColor.neutral200,
                          style: PwTextStyle.footnote,
                          softWrap: false,
                          underline: true,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final url = get<StakingDetailsBloc>().getProvUrl();
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: Spacing.large,
                      top: Spacing.xLarge,
                    ),
                    child: PwIcon(
                      PwIcons.newWindow,
                      color: Theme.of(context).colorScheme.neutralNeutral,
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
