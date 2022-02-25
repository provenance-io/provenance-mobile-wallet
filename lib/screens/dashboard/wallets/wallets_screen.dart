import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/dashboard/add_wallet.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/wallets/wallet_item.dart';
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
  final _screenBottom = 130;
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
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - _screenBottom,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            StreamBuilder<Map<WalletDetails, int>>(
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
                            isSelected:
                                wallet.address == selectedWallet.address,
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
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.large,
              ),
              child: PwOutlinedButton(
                Strings.createWallet,
                onPressed: () {
                  Navigator.of(context).push(AddWallet().route());
                },
              ),
            ),
            VerticalSpacer.largeX4(),
          ]),
        ),
      ),
    );
  }
}
