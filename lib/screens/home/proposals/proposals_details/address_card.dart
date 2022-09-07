import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AddressCard extends StatefulWidget {
  final String title;
  final String address;

  const AddressCard({
    Key? key,
    required this.title,
    required this.address,
  }) : super(key: key);

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.large),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.neutral700,
        ),
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.neutral700,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HorizontalSpacer.medium(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PwText(
                  widget.title,
                  style: PwTextStyle.body,
                  color: PwColor.neutralNeutral,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.fade,
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
                        ? widget.address
                        : abbreviateAddressAlt(widget.address),
                    color: PwColor.neutral200,
                    style: PwTextStyle.footnote,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final url = get<ProposalsBloc>().getExplorerUrl(widget.address);
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.large),
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
