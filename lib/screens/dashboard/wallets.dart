import 'package:flutter/services.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/fw_dialog.dart';
import 'package:flutter_tech_wallet/common/widgets/modal_loading.dart';
import 'package:flutter_tech_wallet/screens/dashboard/add_wallet.dart';
import 'package:flutter_tech_wallet/screens/dashboard/rename_wallet_dialog.dart';
import 'package:flutter_tech_wallet/util/router_observer.dart';
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
      ModalLoadingRoute.showLoading("Loading Wallets", context);
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
                )),
            HorizontalSpacer.medium(),
          ],
          title: FwText('Wallets',
              color: FwColor.globalNeutral550, style: FwTextStyle.h6),
          leading: IconButton(
            icon: FwIcon(
              FwIcons.back,
              size: 24,
              color: Color(0xFF3D4151),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _buildBody());
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
                          'Selected Wallet',
                          color: FwColor.globalNeutral550,
                          style: FwTextStyle.sBold,
                        ),
                      ],
                    )),
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
                )
              ])));
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
                  'All Wallets',
                  color: FwColor.globalNeutral550,
                  style: FwTextStyle.sBold,
                ),
              ],
            )),
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
                itemCount: wallets.length))
      ],
    );
  }
}

class WalletItem extends StatelessWidget {
  final WalletDetails item;
  Offset? _tapPosition;
  VoidCallback reload;

  WalletItem(this.item, this.reload);

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VerticalSpacer.small(),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                FwText(item.accountName,
                    color: FwColor.globalNeutral550, style: FwTextStyle.m),
                HorizontalSpacer.small(),
                Container(
                  height: 26,
                  width: 46,
                  decoration: BoxDecoration(
                      color: Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(13.0)),
                  child: Center(
                      child: FwText('Basic',
                          color: FwColor.globalNeutral550,
                          style: FwTextStyle.xs)),
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
                                overlay.size // Bigger rect, the entire screen
                            ),
                        items: [
                          if (!item.isSelected)
                            PopupMenuItem<MenuOperation>(
                              value: MenuOperation.select,
                              child: FwText('Select'),
                            ),
                          PopupMenuItem<MenuOperation>(
                            value: MenuOperation.rename,
                            child: FwText('Rename'),
                          ),
                          if (!item.isSelected)
                            PopupMenuItem<MenuOperation>(
                              value: MenuOperation.delete,
                              child: FwText('Remove'),
                            ),
                        ],
                      );

                      if (result == MenuOperation.rename) {
                        final result = await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => RenameWalletDialog(
                                currentName: item.accountName));
                        if (result != null) {
                          await ProvWalletFlutter.renameWallet(
                              item.id, result as String);
                          reload.call();
                        }
                      } else if (result == MenuOperation.delete) {
                        final dialogResult = await FwDialog.showConfirmation(
                            context,
                            message:
                                'Are you sure you want to remove this wallet?',
                            confirmText: 'Yes',
                            cancelText: 'Cancel');
                        if (dialogResult == true) {
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
                      color: Colors.white,
                      child: Center(
                          child: FwIcon(FwIcons.menuIcon,
                              color: Theme.of(context)
                                  .colorScheme
                                  .globalNeutral550)),
                    ))
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
                      style: FwTextStyle.m),
                  HorizontalSpacer.medium(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: item.address));
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: FwText('Address copied')));
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
                  )
                ],
              )),
          VerticalSpacer.medium(),
        ],
      ),
    );
  }
}

enum MenuOperation { select, rename, delete }
