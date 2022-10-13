import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/add_account_flow.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/home/accounts/account_cell.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_bloc.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AccountsScreenState();
  }

  static final keySelectAccountButton =
      ValueKey('$AccountsScreen.select_account_button');
}

class AccountsScreenState extends State<AccountsScreen> {
  final _listKey = GlobalKey<AnimatedListState>();
  final _subscriptions = CompositeSubscription();
  CompositeSubscription _providerSubscriptions = CompositeSubscription();
  late final AccountsBloc _bloc;
  final List<Account> _accountIds = <Account>[];
  final ValueNotifier<String?> _selectedId = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _subscriptions.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _bloc = Provider.of<AccountsBloc>(context);

    _providerSubscriptions.cancel();
    final providerSubscriptions = CompositeSubscription();

    _bloc.accountsStream.listen(_onAccountStreamChanged).addTo(_subscriptions);
    _bloc.loading
        .listen((e) => _onLoading(context, e))
        .addTo(providerSubscriptions);
    _providerSubscriptions = providerSubscriptions;

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
                child: AnimatedList(
                  key: _listKey,
                  initialItemCount: _accountIds.length,
                  itemBuilder: (
                    context,
                    index,
                    animation,
                  ) {
                    final account = _bloc.getAccountAtIndex(index);

                    return _cellBuilder(context, animation, account);
                  },
                )),
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

  void _onAccountStreamChanged(AccountsBlocState state) {
    final animatedState = _listKey.currentState;
    if (animatedState == null) {
      return;
    }

    animatedState.setState(() {
      final existingIds = _accountIds.map((e) => e.id).toList();
      final stateIds = state.accounts.map((e) => e.id).toList();

      for (var index = 0; index < _accountIds.length; index++) {
        if (!stateIds.contains(existingIds[index])) {
          final account = _accountIds[index];
          animatedState.removeItem(
              index,
              (context, animation) =>
                  _cellBuilder(context, animation, account));
        }
      }

      int offset = 0;
      for (var index = 0; index < stateIds.length; index++) {
        if (!existingIds.contains(stateIds[index])) {
          animatedState.insertItem(existingIds.length + offset);
          offset++;
        }
      }
      _accountIds.replaceRange(0, _accountIds.length, state.accounts);
      _selectedId.value = state.selectedAccount;
    });
  }

  Widget _cellBuilder(
      BuildContext context, Animation<double> animation, Account account) {
    return SlideTransition(
      key: ValueKey(account.id),
      position: animation.drive(
        Tween(
          begin: Offset(1, 0),
          end: Offset(0, 0),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 1,
        ),
        child: _getItem(account),
      ),
    );
  }

  void _onLoading(BuildContext context, bool loading) {
    if (loading) {
      ModalLoadingRoute.showLoading(context);
    } else {
      ModalLoadingRoute.dismiss(context);
    }
  }

  Widget _getItem(Account account) {
    final state = _bloc.accountsStream.value;
    final isSelected = account.id == state.selectedAccount;

    return GestureDetector(
      key: AccountsScreen.keySelectAccountButton,
      child: AccountCell(
        account: account,
        isSelected: isSelected,
        key: ValueKey(account.id),
      ),
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (isSelected ||
            (account is MultiAccount && account is! TransactableAccount)) {
          return;
        } else {
          await _bloc.selectAccount(account);
        }
      },
    );
  }
}
