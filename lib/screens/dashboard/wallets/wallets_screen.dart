import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/dashboard/add_wallet.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/rename_wallet_dialog.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletsScreenState();
  }
}

class WalletsScreenState extends State<WalletsScreen>
    with RouteAware, WidgetsBindingObserver {
  late DashboardBloc _bloc;

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    RouterObserver.instance.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    RouterObserver.instance.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _bloc = get<DashboardBloc>();
    _bloc.loadAllWallets();
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.wallets,
      ),
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        _showAllWallets(),
        Expanded(
          child: Container(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.large,
          ),
          child: PwButton(
            showAlternate: true,
            child: PwText(
              Strings.createWallet,
            ),
            onPressed: () {
              Navigator.of(context).push(AddWallet().route());
            },
          ),
        ),
        VerticalSpacer.largeX4(),
      ]),
    );
  }

  Widget _showAllWallets() {
    return StreamBuilder<Map<WalletDetails, int>>(
      initialData: _bloc.walletMap.value,
      stream: _bloc.walletMap,
      builder: (context, snapshot) {
        var wallets = snapshot.data?.keys.toList() ?? [];
        var numAssets = snapshot.data?.values.toList() ?? [];
        var selectedWallet = _bloc.selectedWallet.value;
        if (wallets.isEmpty || null == selectedWallet) {
          return Container();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VerticalSpacer.medium(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xxLarge,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  var wallet = wallets[index];

                  return WalletItem(
                    item: wallet,
                    isSelected: wallet.address == selectedWallet.address,
                    reload: () {
                      _bloc.loadAllWallets();
                    },
                    numAssets: numAssets[index],
                  );
                },
                separatorBuilder: (context, index) {
                  return VerticalSpacer.custom(spacing: 1);
                },
                itemCount: wallets.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

// TODO: Should be StatefulWidget since it's not immutable?
class WalletItem extends StatelessWidget {
  WalletItem({
    required this.item,
    required bool isSelected,
    required this.reload,
    required this.numAssets,
  }) : _isSelected = isSelected;

  Offset? _tapPosition;

  final bool _isSelected;

  final WalletDetails item;
  VoidCallback reload;
  int numAssets;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    return Container(
      color: _isSelected ? colorScheme.secondary650 : colorScheme.neutral700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.xLarge,
              vertical: Spacing.large,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwText(
                  item.name,
                  style: PwTextStyle.bodyBold,
                ),
                PwText(
                  Strings.numAssets(numAssets),
                  style: PwTextStyle.bodySmall,
                ),

                //HorizontalSpacer.small(),
              ],
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
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [],
                  );
                },
              );
              final result = await showMenu(
                context: context,
                position: RelativeRect.fromRect(
                  (_tapPosition ?? Offset(0, 0)) &
                      Size(40, 40), // smaller rect, the touch area
                  Offset.zero & overlay.size, // Bigger rect, the entire screen
                ),
                items: [
                  if (!_isSelected)
                    PopupMenuItem<MenuOperation>(
                      value: MenuOperation.select,
                      child: PwText(
                        Strings.select,
                        color: PwColor.neutral550,
                      ),
                    ),
                  PopupMenuItem<MenuOperation>(
                    value: MenuOperation.rename,
                    child: PwText(
                      Strings.rename,
                      color: PwColor.neutral550,
                    ),
                  ),
                  if (!_isSelected)
                    PopupMenuItem<MenuOperation>(
                      value: MenuOperation.delete,
                      child: PwText(
                        Strings.remove,
                        color: PwColor.neutral550,
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
            child: SizedBox(
              width: 60,
              height: 60,
              child: Center(
                child: PwIcon(
                  PwIcons.ellipsis,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                ),
              ),
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
