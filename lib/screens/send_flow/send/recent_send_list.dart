import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_bloc.dart';
import 'package:provenance_wallet/util/strings.dart';

final _dateFormatter = DateFormat("MM/dd/yy");

class RecentSendCell extends StatelessWidget {
  const RecentSendCell(this.recentAddress, { Key? key })
    : super(key: key);

  final RecentAddress? recentAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Spacing.medium,
        horizontal: Spacing.medium,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildChild(),
          ) ,
          Center(
            child: Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }

  Widget _buildChild() {
    return (recentAddress == null)?
      PwText(Strings.ViewAllLabel) :
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          PwText(
            recentAddress!.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: Spacing.medium,
          ),
          PwText(
            _dateFormatter.format(recentAddress!.lastSend),
            style: PwTextStyle.caption,
          ),
        ],
      );
  }
}

class RecentSendList extends StatelessWidget {
  const RecentSendList(
      this.recentAddresses,
      this.onRecentSendClicked,
      this.onViewAllClicked,
      {
        Key? key,
      })
    : super(key: key);

  final List<RecentAddress> recentAddresses;
  final void Function(RecentAddress address) onRecentSendClicked;
  final VoidCallback  onViewAllClicked;

  @override
  Widget build(BuildContext context) {
    if(recentAddresses.isEmpty) {
      return Center (
        child: PwText(Strings.noRecentSends),
      );
    }

    return ListView.separated(
      itemCount: recentAddresses.length + 1,
      separatorBuilder: (context, index) => PwDivider(),
      itemBuilder: (context, index) {
        final address = (index < recentAddresses.length)? recentAddresses[index] : null;
        final cell = RecentSendCell(
          address,
        );

        return GestureDetector(
          child: cell,
          onTap: () {
            if(address == null) {
              onViewAllClicked();
            }
            else {
              onRecentSendClicked(address);
            }
          },
        );
      },
    );
  }
}