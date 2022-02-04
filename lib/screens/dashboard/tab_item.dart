import 'package:provenance_wallet/common/fw_design.dart';

class TabItem extends StatelessWidget {
  TabItem(
    bool this.isCurrent,
    String this.tabName,
    String this.tabAsset, {
    bool this.isLoading = false,
  });
  final bool isCurrent;
  final bool isLoading;
  final String tabAsset;
  final String tabName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          VerticalSpacer.custom(spacing: 10),
          SizedBox(
            width: Spacing.large,
            height: Spacing.large,
            child: !isLoading
                ? FwIcon(
                    tabAsset,
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary7
                        : Theme.of(context).colorScheme.globalNeutral350,
                  )
                : const CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 28),
            child: Text(
              tabName,
              style: Theme.of(context).textTheme.extraSmallBold.copyWith(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary7
                        : Theme.of(context).colorScheme.globalNeutral350,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
