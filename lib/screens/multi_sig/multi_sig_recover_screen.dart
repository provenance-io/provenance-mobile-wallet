import 'package:flutter_svg/svg.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/accounts/multi_sig_remote_account_item.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class MultiSigRecoverBloc {
  void submitRecoverFromAccount({
    required BuildContext context,
    required MultiSigRemoteAccount account,
    required BasicAccount linkedAccount,
  });
}

class MultiSigRecoverScreen extends StatefulWidget {
  const MultiSigRecoverScreen({
    required MultiSigRecoverBloc bloc,
    Key? key,
  })  : _bloc = bloc,
        super(key: key);

  final MultiSigRecoverBloc _bloc;

  @override
  State<MultiSigRecoverScreen> createState() => _MultiSigRecoverScreenState();
}

class _MultiSigRecoverScreenState extends State<MultiSigRecoverScreen> {
  final accountService = get<AccountService>();
  final multiSigClient = get<MultiSigClient>();

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
        title: Strings.of(context).multiSigRecoverTitle,
        leadingIcon: PwIcons.back,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Spacing.large,
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
                          Strings.of(context).multiSigRecoverLoadError,
                          color: PwColor.neutralNeutral,
                          style: PwTextStyle.body,
                        );
                      }

                      final children = <Widget>[];
                      if (loadData.datas.isNotEmpty) {
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
                      } else {
                        children.add(
                            SvgPicture.asset(ImagePaths().warningDialogIcon));
                        children.add(VerticalSpacer.xxLarge());
                        children.add(Text(
                          Strings.of(context).multiSigRecoverPleaseNote,
                          style: Theme.of(context).textTheme.titleMedium,
                        ));
                        children.add(VerticalSpacer.medium());
                        children.add(Center(
                          child: Text(
                            Strings.of(context)
                                .multiSigRecoverNoAccountsToRecover,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.body,
                          ),
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
                  VerticalSpacer.large(),
                  PwButton(
                    child: PwText(Strings.of(context).next),
                    enabled: selectedData != null,
                    onPressed: () {
                      widget._bloc.submitRecoverFromAccount(
                        context: context,
                        account: selectedData!.account,
                        linkedAccount: selectedData!.linkedAccount,
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

  String _uniqueId({
    required String remoteId,
    required String linkedAccountId,
  }) =>
      '$remoteId-$linkedAccountId';

  Future<_LoadData> _load() async {
    final accounts = await accountService.getAccounts();
    final basicAccounts = accounts.whereType<BasicAccount>();
    final multiAccountRemoteIds = accounts
        .whereType<MultiAccount>()
        .map(
          (e) => _uniqueId(
            remoteId: e.remoteId,
            linkedAccountId: e.linkedAccount.id,
          ),
        )
        .toSet();

    var error = false;
    final recoverableRemoteAccounts = <String, _MultiSigAccountData>{};

    for (var basicAccount in basicAccounts) {
      final remoteAccounts = await multiSigClient.getAccounts(
        address: basicAccount.address,
        coin: basicAccount.coin,
      );

      if (remoteAccounts == null) {
        error = true;
      }

      for (var remoteAccount in remoteAccounts ?? <MultiSigRemoteAccount>[]) {
        final uniqueId = _uniqueId(
          remoteId: remoteAccount.remoteId,
          linkedAccountId: basicAccount.id,
        );

        if (!multiAccountRemoteIds.contains(uniqueId) &&
            !recoverableRemoteAccounts.containsKey(uniqueId)) {
          recoverableRemoteAccounts[uniqueId] = _MultiSigAccountData(
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
