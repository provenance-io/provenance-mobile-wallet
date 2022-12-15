import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/util/deep_link_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends Disposable {
  HomeBloc() {
    get<DeepLinkService>().link.listen(_onDeepLink).addTo(_subscriptions);
    get<KeyValueService>()
        .stream<String>(PrefKey.multiSigInviteUri)
        .listen(_onMultiSigInviteDeepLink)
        .addTo(_subscriptions);
    _transactionHandler.transaction
        .listen(_onTransaction)
        .addTo(_subscriptions);
    _accountService.events.selected
        .distinct()
        .listen(_onSelected)
        .addTo(_subscriptions);

    prefTriggeredReload(_) {
      load();
    }

    get<KeyValueService>()
        .stream<bool>(PrefKey.httpClientDiagnostics500)
        .skip(1) // the stream always emits an event for its initial value
        .listen(prefTriggeredReload)
        .addTo(_subscriptions);
  }

  final _isLoading = BehaviorSubject.seeded(false);
  final _assetList = BehaviorSubject<List<Asset>?>.seeded([]);
  final _multiSigInviteDeepLink = PublishSubject<String>();
  final _error = PublishSubject<String>();

  final _subscriptions = CompositeSubscription();

  final _transactionHandler = get<TransactionHandler>();
  final _accountService = get<AccountService>();
  final _assetClient = get<AssetClient>();

  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<List<Asset>?> get assetList => _assetList;
  Stream<String> get error => _error;
  Stream<String> get multiSigInviteDeepLink => _multiSigInviteDeepLink;

  Future<void> load({
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _isLoading.tryAdd(true);
    }

    try {
      final account = _accountService.events.selected.value;

      var assetList = <Asset>[];

      if (account != null) {
        assetList = await _assetClient.getAssets(
          account.coin,
          account.address,
        );
      }

      _assetList.tryAdd(assetList);
    } finally {
      if (showLoading) {
        _isLoading.tryAdd(false);
      }
    }
  }

  Future<void> selectAccount({required String id}) async {
    await get<AccountService>().selectAccount(id: id);
  }

  Future<void> renameAccount({
    required String id,
    required String name,
  }) async {
    await get<AccountService>().renameAccount(
      id: id,
      name: name,
    );
  }

  Future<void> resetAccounts() async {
    await get<AccountService>().resetAccounts();
    await get<CipherService>().deletePin();
    get<LocalAuthHelper>().reset();
  }

  @override
  FutureOr onDispose() {
    _subscriptions.dispose();
    _isLoading.close();
    _assetList.close();
    _error.close();
    _multiSigInviteDeepLink.close();
  }

  void _onSelected(Account? details) {
    load();
  }

  void _onTransaction(TransactionResponse response) {
    load();
  }

  void _onMultiSigInviteDeepLink(KeyValueData<String> kvData) async {
    final link = kvData.data;
    if (link != null) {
      await get<KeyValueService>().removeString(PrefKey.multiSigInviteUri);

      _multiSigInviteDeepLink.add(link);
    }
  }

  Future<void> _onDeepLink(Uri link) async {
    final path = link.path;
    switch (path) {
      case '/wallet-connect':
        _handleWalletConnectLink(link);
        break;
    }
  }

  Future<void> _handleWalletConnectLink(Uri link) async {
    final address = getWalletConnectAddress(link);
    if (address != null) {
      // this event fires before the normal app lifecycle
      // so just store the requested address and allow
      // wallet connect service lifecycle handling
      // to deal with it
      await get<KeyValueService>()
          .setString(PrefKey.deepLinkAddress, address.raw);
    }
  }
}
