import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_theme.dart';

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
            width: Spacing.xLarge,
            height: Spacing.xLarge,
            child: !isLoading
                ? PwIcon(
                    tabAsset,
                    size: 24,
                    color: isCurrent
                        ? Theme.of(context).colorScheme.white
                        : Theme.of(context).colorScheme.provenanceNeutral550,
                  )
                : const CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 28),
            child: PwText(
              tabName,
              style: PwTextStyle.footnote,
              color: PwColor.white,
            ),
          ),
        ],
      ),
    );
  }
}
