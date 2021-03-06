import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/accounts/multi_sig_remote_account_item.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigRecoverScreen extends StatefulWidget {
  const MultiSigRecoverScreen({
    required this.bloc,
    Key? key,
  }) : super(key: key);

  final AddAccountFlowBloc bloc;

  @override
  State<MultiSigRecoverScreen> createState() => _MultiSigRecoverScreenState();
}

class _MultiSigRecoverScreenState extends State<MultiSigRecoverScreen> {
  final accountService = get<AccountService>();
  final multiSigService = get<MultiSigService>();

  _MultiSigAccountData? selectedData;

  late final Future<_LoadData> loadFuture;

  @override
  void initState() {
    super.initState();

    loadFuture = _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.multiSigRecoverTitle,
        leadingIcon: PwIcons.back,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Spacing.xxLarge,
              ),
              child: Column(
                children: [
                  VerticalSpacer.xxLarge(),
                  FutureBuilder<_LoadData>(
                    future: loadFuture,
                    builder: (context, snapshot) {
                      final loadData = snapshot.data;
                      if (loadData == null) {
                        return CircularProgressIndicator();
                      }

                      if (loadData.error) {
                        return PwText(
                          Strings.multiSigRecoverLoadError,
                          color: PwColor.neutralNeutral,
                          style: PwTextStyle.body,
                        );
                      }

                      final children = <Widget>[];
                      for (var data in loadData.datas) {
                        final child = _SelectableTextButton(
                          data: data,
                          isSelected: selectedData?.account.remoteId ==
                              data.account.remoteId,
                          onPressed: () {
                            setState(() {
                              final remoteId = data.account.remoteId;

                              selectedData =
                                  selectedData?.account.remoteId == remoteId
                                      ? null
                                      : data;
                            });
                          },
                        );

                        children.add(child);
                        children.add(SizedBox(
                          height: 1,
                        ));
                      }

                      return Column(
                        children: children,
                      );
                    },
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  PwButton(
                    child: PwText(Strings.next),
                    enabled: selectedData != null,
                    onPressed: () {
                      widget.bloc.submitRecoverFromAccount(
                        selectedData!.account,
                        selectedData!.linkedAccount,
                      );
                    },
                  ),
                  VerticalSpacer.largeX4(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<_LoadData> _load() async {
    final accounts = await accountService.getAccounts();
    final basicAccounts = accounts.whereType<BasicAccount>();
    final multiAccountRemoteIds =
        accounts.whereType<MultiAccount>().map((e) => e.remoteId).toSet();

    var error = false;
    final recoverableRemoteAccounts = <String, _MultiSigAccountData>{};

    for (var basicAccount in basicAccounts) {
      final remoteAccounts = await multiSigService.getAccounts(
        publicKey: basicAccount.publicKey,
      );

      if (remoteAccounts == null) {
        error = true;
      }

      for (var remoteAccount in remoteAccounts ?? <MultiSigRemoteAccount>[]) {
        final remoteId = remoteAccount.remoteId;

        if (!multiAccountRemoteIds.contains(remoteId) &&
            !recoverableRemoteAccounts.containsKey(remoteId)) {
          recoverableRemoteAccounts[remoteAccount.remoteId] =
              _MultiSigAccountData(
            account: remoteAccount,
            linkedAccount: basicAccount,
          );
        }
      }
    }

    return _LoadData(
      datas: recoverableRemoteAccounts.values.toList(),
      error: error,
    );
  }
}

class _LoadData {
  _LoadData({
    required this.datas,
    this.error = false,
  });

  final List<_MultiSigAccountData> datas;
  final bool error;
}

class _SelectableTextButton extends StatefulWidget {
  const _SelectableTextButton({
    required this.data,
    required this.isSelected,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  final void Function()? onPressed;
  final bool isSelected;
  final _MultiSigAccountData data;

  @override
  State<_SelectableTextButton> createState() => _SelectableTextButtonState();
}

class _SelectableTextButtonState extends State<_SelectableTextButton> {
  var isActive = false;

  @override
  void initState() {
    super.initState();

    isActive = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all(Theme.of(context).colorScheme.neutral700),
      shape: MaterialStateProperty.all(RoundedRectangleBorder()),
      padding: MaterialStateProperty.all(EdgeInsets.zero),
    );

    final selectedStyle = ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all(Theme.of(context).colorScheme.secondary650),
      shape: MaterialStateProperty.all(RoundedRectangleBorder()),
      padding: MaterialStateProperty.all(EdgeInsets.zero),
    );

    return TextButton(
      onPressed: widget.onPressed,
      style: widget.isSelected ? selectedStyle : style,
      onHover: (value) {
        setState(() {
          isActive = value ? true : widget.isSelected;
        });
      },
      child: MultiSigRemoteAccountItem(
        account: widget.data.account,
        linkedAccount: widget.data.linkedAccount,
        isActive: widget.isSelected,
      ),
    );
  }
}

class _MultiSigAccountData {
  _MultiSigAccountData({
    required this.account,
    required this.linkedAccount,
  });

  final MultiSigRemoteAccount account;
  final BasicAccount linkedAccount;
}
