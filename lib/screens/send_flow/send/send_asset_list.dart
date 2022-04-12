import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';

class SendAssetCell extends StatelessWidget {
  const SendAssetCell(
    this.asset, {
    Key? key,
  }) : super(key: key);

  final SendAsset asset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(Spacing.xSmall),
          child: Image.network(
            asset.imageUrl,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return asset.displayDenom.toLowerCase() == 'hash'
                  ? PwIcon(PwIcons.hashLogo)
                  : PwIcon(
                      PwIcons.provenance,
                      color: Theme.of(context).colorScheme.logo,
                    );
            },
          ),
        ),
        HorizontalSpacer.small(),
        Expanded(
          child: PwText(
            asset.displayDenom,
            maxLines: 1,
          ),
        ),
        SizedBox(
          width: 105,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: PwAutoSizingText(
                  asset.displayFiatAmount,
                ),
              ),
              Expanded(
                child: PwAutoSizingText(
                  asset.displayAmount,
                  style: PwTextStyle.caption,
                  height: 25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SendAssetList extends StatelessWidget {
  const SendAssetList(
    this.assets,
    this.selectedAsset,
    this.onAssetChanged, {
    Key? key,
  }) : super(key: key);

  final List<SendAsset> assets;
  final SendAsset? selectedAsset;
  final void Function(SendAsset asset) onAssetChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child;

    if (assets.isEmpty) {
      child = Center(
        child: PwText("Loading assets"),
      );
    } else {
      final selectedDenom = this.selectedAsset?.displayDenom ?? "";
      final selectedAsset = assets.firstWhere(
        (asset) => asset.displayDenom == selectedDenom,
        orElse: () => assets.first,
      );

      child = PwDropDown<SendAsset>(
        isExpanded: true,
        itemHeight: 50,
        initialValue: selectedAsset,
        items: assets,
        onValueChanged: onAssetChanged,
        builder: (item) => SendAssetCell(item),
        dropdownColor: theme.canvasColor,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.small,
        horizontal: Spacing.small,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: theme.colorScheme.neutral250,
        ),
        color: theme.colorScheme.neutral700,
      ),
      child: child,
    );
  }
}
