import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/staking/pw_avatar.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class ValidatorCard extends StatefulWidget {
  const ValidatorCard({
    Key? key,
    required this.validator,
  }) : super(key: key);

  final DetailedValidator validator;

  @override
  State<ValidatorCard> createState() => _ValidatorCardState();
}

class _ValidatorCardState extends State<ValidatorCard> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.neutral700,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: Spacing.medium),
            child: PwAvatar(
              initial: widget.validator.moniker.substring(0, 1),
              imgUrl: widget.validator.imgUrl ?? "",
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
                        widget.validator.moniker,
                        style: PwTextStyle.body,
                        color: PwColor.neutralNeutral,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: Spacing.xSmall,
                  ),
                  child: PwText(
                    widget.validator.description,
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
          //Expanded(child: Container()),
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
              padding:
                  EdgeInsets.only(left: Spacing.large, top: Spacing.xLarge),
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
