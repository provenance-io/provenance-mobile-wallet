import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/fw_dialog.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/dashboard/add_wallet.dart';
import 'package:provenance_wallet/screens/dashboard/rename_wallet_dialog.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class Wallets extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletsState();
  }
}

class WalletsState extends State<Wallets>
    with RouteAware, WidgetsBindingObserver {
  List<WalletDetails> wallets = [];
  WalletDetails? selectedWallet;

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    RouterObserver.instance.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    loadWallets();
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    RouterObserver.instance.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    loadWallets();
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  void loadWallets() async {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      ModalLoadingRoute.showLoading(Strings.loadingWallets, context);
      final walletList = await ProvWalletFlutter.getWallets();
      ModalLoadingRoute.dismiss(context);
      setState(() {
        selectedWallet =
            walletList.where((element) => element.isSelected).first;
        wallets = walletList.where((element) => !element.isSelected).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.otherBackground,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(AddWallet().route());
            },
            child: FwIcon(
              FwIcons.plus,
              color: Theme.of(context).colorScheme.globalNeutral450,
              size: 24,
            ),
          ),
          HorizontalSpacer.medium(),
        ],
        title: FwText(
          Strings.wallets,
          color: FwColor.globalNeutral550,
          style: FwTextStyle.h6,
        ),
        leading: IconButton(
          icon: FwIcon(
            FwIcons.back,
            size: 24,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (selectedWallet != null) {
      final selWallet = selectedWallet!;

      return Container(
        color: Theme.of(context).colorScheme.otherBackground,
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FwText(
                    Strings.selectedWallet,
                    color: FwColor.globalNeutral550,
                    style: FwTextStyle.sBold,
                  ),
                ],
              ),
            ),
            VerticalSpacer.small(),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: WalletItem(selWallet, () {
                loadWallets();
              }),
            ),
            _showAllWallets(),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.otherBackground,
              ),
            ),
          ]),
        ),
      );
    }

    return Container();
  }

  Widget _showAllWallets() {
    if (wallets.isEmpty) {
      return Container();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VerticalSpacer.medium(),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FwText(
                Strings.allWallets,
                color: FwColor.globalNeutral550,
                style: FwTextStyle.sBold,
              ),
            ],
          ),
        ),
        VerticalSpacer.medium(),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return WalletItem(wallets[index], () {
                loadWallets();
              });
            },
            separatorBuilder: (context, index) {
              return VerticalSpacer.medium();
            },
            itemCount: wallets.length,
          ),
        ),
      ],
    );
  }
}

// TODO: Should be StatefulWidget since it's not immutable?
class WalletItem extends StatelessWidget {
  WalletItem(this.item, this.reload);

  Offset? _tapPosition;

  final WalletDetails item;
  VoidCallback reload;

  @override
  Widget build(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    return Container(
      color: Theme.of(context).colorScheme.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VerticalSpacer.small(),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                FwText(
                  item.accountName,
                  color: FwColor.globalNeutral550,
                  style: FwTextStyle.m,
                ),
                HorizontalSpacer.small(),
                Container(
                  height: 26,
                  width: 46,
                  decoration: BoxDecoration(
                    color: Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                  child: Center(
                    child: FwText(
                      Strings.basic,
                      color: FwColor.globalNeutral550,
                      style: FwTextStyle.xs,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                GestureDetector(
                  onTapDown: (details) {
                    _storePosition(details);
                  },
                  onTap: () async {
                    final result = await showMenu(
                      context: context,
                      position: RelativeRect.fromRect(
                        (_tapPosition ?? Offset(0, 0)) &
                            Size(40, 40), // smaller rect, the touch area
                        Offset.zero &
                            overlay.size, // Bigger rect, the entire screen
                      ),
                      items: [
                        if (!item.isSelected)
                          PopupMenuItem<MenuOperation>(
                            value: MenuOperation.select,
                            child: FwText(Strings.select),
                          ),
                        PopupMenuItem<MenuOperation>(
                          value: MenuOperation.rename,
                          child: FwText(Strings.rename),
                        ),
                        if (!item.isSelected)
                          PopupMenuItem<MenuOperation>(
                            value: MenuOperation.delete,
                            child: FwText(Strings.remove),
                          ),
                      ],
                    );

                    if (result == MenuOperation.rename) {
                      final result = await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => RenameWalletDialog(
                          currentName: item.accountName,
                        ),
                      );
                      if (result != null) {
                        await ProvWalletFlutter.renameWallet(
                          item.id,
                          result as String,
                        );
                        reload.call();
                      }
                    } else if (result == MenuOperation.delete) {
                      final dialogResult = await FwDialog.showConfirmation(
                        context,
                        message: Strings.removeThisWallet,
                        confirmText: Strings.yes,
                        cancelText: Strings.cancel,
                      );
                      if (dialogResult) {
                        await ProvWalletFlutter.removeWallet(item.id);
                        reload.call();
                      }
                    } else if (result == MenuOperation.select) {
                      await ProvWalletFlutter.selectWallet(item.id);
                      reload.call();
                    }
                    var y = 0;
                    y++;
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Theme.of(context).colorScheme.white,
                    child: Center(
                      child: FwIcon(
                        FwIcons.menuIcon,
                        color: Theme.of(context).colorScheme.globalNeutral550,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          VerticalSpacer.medium(),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                FwText(
                  '${item.address.substring(0, 5)}...${item.address.substring(30)}',
                  color: FwColor.globalNeutral550,
                  style: FwTextStyle.m,
                ),
                HorizontalSpacer.medium(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: item.address));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: FwText(Strings.addressCopied)),
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    child: FwIcon(
                      FwIcons.copy,
                      color: Theme.of(context).colorScheme.globalNeutral550,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          VerticalSpacer.medium(),
        ],
      ),
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}

enum MenuOperation {
  select,
  rename,
  delete,
}
