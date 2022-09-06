import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/util/assets.dart';

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
          child: Assets.getSvgPictureFrom(
            denom: asset.displayDenom,
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
  static final keySelectAssetButton =
      ValueKey('$SendAssetList.select_asset_button');
  static Key keyDropDownItem(String asset) =>
      ValueKey('$SendAssetList.dropdown_button_$asset');

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
        key: SendAssetList.keySelectAssetButton,
        isExpanded: true,
        itemHeight: 50,
        value: selectedAsset,
        items: assets,
        onValueChanged: onAssetChanged,
        builder: (item) => SendAssetCell(
          item,
          key: keyDropDownItem(item.displayDenom),
        ),
        selectedItemBuilder: (item) => SendAssetCell(
          item,
        ),
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
