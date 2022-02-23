import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/dashboard/add_wallet.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/rename_wallet_dialog.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';

class Wallets extends StatefulWidget {
  const Wallets({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletsState();
  }
}

class WalletsState extends State<Wallets>
    with RouteAware, WidgetsBindingObserver {
  List<WalletDetails> _wallets = [];
  WalletDetails? _selectedWallet;

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
      final walletService = await get<WalletService>();
      final selectedWallet = await walletService.getSelectedWallet();
      final wallets = await walletService.getWallets();
      final filteredWallets = wallets
          .where(
            (e) => e.id != selectedWallet?.id,
          )
          .toList();

      ModalLoadingRoute.dismiss(context);
      setState(() {
        _selectedWallet = selectedWallet;
        _wallets = filteredWallets;
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
            child: PwIcon(
              PwIcons.plus,
              color: Theme.of(context).colorScheme.globalNeutral450,
              size: 24,
            ),
          ),
          HorizontalSpacer.medium(),
        ],
        title: PwText(
          Strings.wallets,
          color: PwColor.globalNeutral550,
          style: PwTextStyle.h6,
        ),
        leading: IconButton(
          icon: PwIcon(
            PwIcons.back,
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
    if (_selectedWallet != null) {
      final selectedWallet = _selectedWallet!;

      return Container(
        color: Theme.of(context).colorScheme.otherBackground,
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  PwText(
                    Strings.selectedWallet,
                    color: PwColor.globalNeutral550,
                    style: PwTextStyle.sBold,
                  ),
                ],
              ),
            ),
            VerticalSpacer.small(),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: WalletItem(
                item: selectedWallet,
                isSelected: true,
                reload: () {
                  loadWallets();
                },
              ),
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
    if (_wallets.isEmpty) {
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
              PwText(
                Strings.allWallets,
                color: PwColor.globalNeutral550,
                style: PwTextStyle.sBold,
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
              return WalletItem(
                item: _wallets[index],
                isSelected: false,
                reload: () {
                  loadWallets();
                },
              );
            },
            separatorBuilder: (context, index) {
              return VerticalSpacer.medium();
            },
            itemCount: _wallets.length,
          ),
        ),
      ],
    );
  }
}

// TODO: Should be StatefulWidget since it's not immutable?
class WalletItem extends StatelessWidget {
  WalletItem({
    required this.item,
    required bool isSelected,
    required this.reload,
  }) : _isSelected = isSelected;

  Offset? _tapPosition;

  final bool _isSelected;

  final WalletDetails item;
  VoidCallback reload;

  @override
  Widget build(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    return Container(
      color: Theme.of(context).colorScheme.neutralNeutral,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VerticalSpacer.small(),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                PwText(
                  item.name,
                  color: PwColor.globalNeutral550,
                  style: PwTextStyle.m,
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
                    child: PwText(
                      Strings.basic,
                      color: PwColor.globalNeutral550,
                      style: PwTextStyle.xs,
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
                        if (!_isSelected)
                          PopupMenuItem<MenuOperation>(
                            value: MenuOperation.select,
                            child: PwText(
                              Strings.select,
                              color: PwColor.globalNeutral550,
                            ),
                          ),
                        PopupMenuItem<MenuOperation>(
                          value: MenuOperation.rename,
                          child: PwText(
                            Strings.rename,
                            color: PwColor.globalNeutral550,
                          ),
                        ),
                        if (!_isSelected)
                          PopupMenuItem<MenuOperation>(
                            value: MenuOperation.delete,
                            child: PwText(
                              Strings.remove,
                              color: PwColor.globalNeutral550,
                            ),
                          ),
                      ],
                    );

                    final bloc = get<DashboardBloc>();

                    if (result == MenuOperation.rename) {
                      final text = await showDialog<String?>(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => RenameWalletDialog(
                          currentName: item.name,
                        ),
                      );
                      if (text != null) {
                        await bloc.renameWallet(
                          id: item.id,
                          name: text,
                        );
                        reload.call();
                      }
                    } else if (result == MenuOperation.delete) {
                      final dialogResult = await PwDialog.showConfirmation(
                        context,
                        message: Strings.removeThisWallet,
                        confirmText: Strings.yes,
                        cancelText: Strings.cancel,
                      );
                      if (dialogResult) {
                        await bloc.removeWallet(id: item.id);
                        reload.call();
                      }
                    } else if (result == MenuOperation.select) {
                      await bloc.selectWallet(id: item.id);
                      reload.call();
                    }
                    var y = 0;
                    y++;
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Theme.of(context).colorScheme.neutralNeutral,
                    child: Center(
                      child: PwIcon(
                        PwIcons.menuIcon,
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
                PwText(
                  item.address.abbreviateAddress(),
                  color: PwColor.globalNeutral550,
                  style: PwTextStyle.m,
                ),
                HorizontalSpacer.medium(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: item.address));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: PwText(Strings.addressCopied)),
                    );
                  },
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: PwIcon(
                      PwIcons.copy,
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
