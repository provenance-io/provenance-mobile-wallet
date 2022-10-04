import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/add_account_flow.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_bloc.dart';
import 'package:provenance_wallet/screens/home/accounts/basic_account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/multi_account_item.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AccountsScreenState();
  }
}

class AccountsScreenState extends State<AccountsScreen> {
  final _listKey = GlobalKey<AnimatedListState>();
  final _subscriptions = CompositeSubscription();
  final _providerSubscriptions = CompositeSubscription();
  final _accountService = get<AccountService>();
  late final AccountsBloc _bloc;

  @override
  void dispose() {
    _subscriptions.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _accountService.events.removed.listen(_onRemoved).addTo(_subscriptions);
  }

  @override
  void didChangeDependencies() {
    _bloc = Provider.of<AccountsBloc>(context);
    _providerSubscriptions.cancel().whenComplete(() {
      _bloc.insert.listen(_onInsert).addTo(_providerSubscriptions);
      _bloc.loading
          .listen((e) => _onLoading(context, e))
          .addTo(_providerSubscriptions);
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).accounts,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: Spacing.large,
                right: Spacing.large,
                top: Spacing.medium,
              ),
              child: StreamBuilder<int>(
                initialData: _bloc.count.value,
                stream: _bloc.count,
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
                      final account = _bloc.getAccountAtIndex(index);

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
                          child: _getItem(account),
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
              Strings.of(context).addAccount,
              onPressed: () {
                Navigator.of(context).push(
                  AddAccountFlow(
                    origin: AddAccountOrigin.accounts,
                    includeMultiSig: true,
                  ).route(),
                );
              },
            ),
          ),
          VerticalSpacer.largeX3(),
        ],
      ),
    );
  }

  void _onRemoved(List<Account> accounts) {
    for (final account in accounts) {
      final index = Provider.of<AccountsBloc>(context, listen: false)
          .removeAccount(account.id);
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
              child: _getItem(account),
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
      ModalLoadingRoute.showLoading(context);
    } else {
      ModalLoadingRoute.dismiss(context);
    }
  }

  Widget _getItem(Account account) {
    Widget item;

    switch (account.kind) {
      case AccountKind.basic:
        item = BasicAccountItem(
          account: account as BasicAccount,
        );
        break;
      case AccountKind.multi:
        item = MultiAccountItem(
          account: account as MultiAccount,
        );

        break;
    }

    return item;
  }
}
