import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_name.dart';
import 'package:provenance_wallet/screens/dashboard/wallets/wallet_item.dart';
import 'package:provenance_wallet/screens/dashboard/wallets/wallets_bloc.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletsScreenState();
  }
}

class WalletsScreenState extends State<WalletsScreen> {
  final _listKey = GlobalKey<AnimatedListState>();
  final _subscriptions = CompositeSubscription();
  final _walletsBloc = WalletsBloc();
  final _walletService = get<WalletService>();

  @override
  void dispose() {
    _subscriptions.dispose();

    super.dispose();

    get.unregister<WalletsBloc>();
  }

  @override
  void initState() {
    super.initState();

    get.registerSingleton(_walletsBloc);

    _walletsBloc.load();

    _walletService.events.removed.listen(_onRemoved).addTo(_subscriptions);
    _walletsBloc.insert.listen(_onInsert).addTo(_subscriptions);
    _walletsBloc.loading
        .listen((e) => _onLoading(context, e))
        .addTo(_subscriptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.wallets,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: Spacing.xxLarge,
                right: Spacing.xxLarge,
                top: Spacing.medium,
              ),
              child: StreamBuilder<int>(
                initialData: _walletsBloc.count.value,
                stream: _walletsBloc.count,
                builder: (context, snapshot) {
                  final count = snapshot.data!;
                  if (count == 0) {
                    return Container();
                  }

                  return AnimatedList(
                    key: _listKey,
                    initialItemCount: count,
                    itemBuilder: (
                      context,
                      index,
                      animation,
                    ) {
                      final wallet = _walletsBloc.getWalletAtIndex(index);

                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: Offset(1, 0),
                            end: Offset(0, 0),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                            bottom: 1,
                          ),
                          child: WalletItem(
                            wallet: wallet,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Spacing.large,
              left: Spacing.large,
              right: Spacing.large,
            ),
            child: PwOutlinedButton(
              Strings.createWallet,
              onPressed: () {
                Navigator.of(context).push(AccountName(
                  WalletAddImportType.dashboardAdd,
                  currentStep: 1,
                  numberOfSteps: 2,
                ).route());
              },
            ),
          ),
          VerticalSpacer.large(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.large,
            ),
            child: PwTextButton(
              child: PwText(
                Strings.recoverWallet,
                style: PwTextStyle.body,
                color: PwColor.neutralNeutral,
              ),
              onPressed: () {
                Navigator.of(context).push(AccountName(
                  WalletAddImportType.dashboardRecover,
                  currentStep: 1,
                  numberOfSteps: 2,
                ).route());
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onRemoved(List<WalletDetails> wallets) {
    for (final wallet in wallets) {
      final index = _walletsBloc.removeWallet(wallet.id);
      if (index != -1) {
        _listKey.currentState?.removeItem(
          index,
          (context, animation) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: Offset(-1, 0),
                  end: Offset(0, 0),
                ),
              ),
              child: WalletItem(
                wallet: wallet,
              ),
            );
          },
        );
      }
    }
  }

  void _onInsert(int index) {
    _listKey.currentState?.insertItem(index);
  }

  void _onLoading(BuildContext context, bool loading) {
    if (loading) {
      ModalLoadingRoute.showLoading('', context);
    } else {
      ModalLoadingRoute.dismiss(context);
    }
  }
}
