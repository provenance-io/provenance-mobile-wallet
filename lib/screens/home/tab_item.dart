import 'package:provenance_wallet/common/pw_design.dart';

class TabItem extends StatelessWidget {
  const TabItem(
    this.isCurrent,
    this.tabName,
    this.tabAsset, {
    Key? key,
    this.isLoading = false,
    this.topPadding = 10,
    this.bottomPadding = 28,
  }) : super(key: key);
  final bool isCurrent;
  final bool isLoading;
  final String tabAsset;
  final String tabName;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          VerticalSpacer.custom(spacing: topPadding),
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
            padding: EdgeInsets.only(top: 5, bottom: bottomPadding),
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
