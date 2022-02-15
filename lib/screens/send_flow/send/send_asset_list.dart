import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_bloc.dart';

class SendAssetCell extends StatelessWidget {
  SendAssetCell(this.asset, { Key? key })
      : super(key: key);

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(Spacing.xSmall),
          child: Image.network(asset.imageUrl),
        ),
        HorizontalSpacer.small(),
        Expanded(
          child: PwText(asset.denom, maxLines: 1,),
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: PwText("${asset.fiatValue}")),
            Expanded(
                child: PwText(
                  "${asset.amount} ${asset.denom}",
                  style: PwTextStyle.caption,
                ),
            ),
          ],
        ),
      ],
    );
  }
}

class SendAssetList extends StatelessWidget {
  SendAssetList(this.assets, this.selectedAsset, this.onAssetChanged, { Key? key })
    : super(key: key);

  final List<Asset> assets;
  final Asset? selectedAsset;
  final void Function(Asset asset) onAssetChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child;

    if(assets.isEmpty) {
      child = Center(
        child: PwText("Loading assets"),
      );
    }
    else {
      final selectedDenom = this.selectedAsset?.denom ?? "";
      final selectedAsset = assets.firstWhere(
            (asset) => asset.denom == selectedDenom,
        orElse: () => assets.first,
      );

      child = PwDropDown<Asset>(
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
          horizontal: Spacing.small
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: theme.colorScheme.primary,
        ),
      ),
      child: child,
    );

  }
}