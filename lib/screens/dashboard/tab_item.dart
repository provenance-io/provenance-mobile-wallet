import 'package:provenance_wallet/common/pw_design.dart';

class TabItem extends StatelessWidget {
  const TabItem(
    this.isCurrent,
    this.tabName,
    this.tabAsset, {
    Key? key,
    this.isLoading = false,
  }) : super(key: key);
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
            width: Spacing.xLarge,
            height: Spacing.xLarge,
            child: !isLoading
                ? PwIcon(
                    tabAsset,
                    size: 24,
                    color: isCurrent
                        ? Theme.of(context).colorScheme.neutralNeutral
                        : Theme.of(context).colorScheme.neutral550,
                  )
                : const CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 28),
            child: PwText(
              tabName,
              style: PwTextStyle.footnote,
              color: PwColor.neutralNeutral,
            ),
          ),
        ],
      ),
    );
  }
}
