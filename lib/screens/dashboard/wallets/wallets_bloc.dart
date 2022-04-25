import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_blockchain_wallet/extension/stream_controller.dart';
import 'package:provenance_blockchain_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_blockchain_wallet/services/models/wallet_details.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_blockchain_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class WalletsBloc implements Disposable {
  WalletsBloc() {
    _walletService.events.added.listen(_onAdded).addTo(_subscriptions);
    _walletService.events.updated.listen(_onUpdated).addTo(_subscriptions);
    _walletService.events.selected.listen(_onSelected).addTo(_subscriptions);
  }

  final _subscriptions = CompositeSubscription();
  final _walletService = get<WalletService>();
  final _assetService = get<AssetService>();
  final _count = BehaviorSubject.seeded(0);

  final _updated = PublishSubject<WalletDetails>();
  final _insert = PublishSubject<int>();
  final _loading = BehaviorSubject.seeded(false);

  Completer? _completer;
  var _wallets = <WalletDetails>[];
  final _assetCounts = <String, int>{};

  ValueStream<int> get count => _count;
  Stream<WalletDetails> get updated => _updated;
  Stream<int> get insert => _insert;
  ValueStream<bool> get loading => _loading;

  Future<void> load() async {
    var completer = _completer;
    if (completer != null) {
      await completer.future;
    }

    completer = Completer();
    _completer = completer;

    _loading.tryAdd(true);

    try {
      final selectedWallet = await _walletService.getSelectedWallet();
      var details = await _walletService.getWallets();
      details.sort((a, b) {
        if (b.id == selectedWallet?.id) {
          return 1;
        } else if (a.id == selectedWallet?.id) {
          return -1;
        } else {
          return 0;
        }
      });

      _wallets = details;
      _count.tryAdd(_wallets.length);
    } finally {
      completer.complete();
      _loading.tryAdd(false);
    }
  }

  WalletDetails getWalletAtIndex(int index) {
    final wallet = _wallets[index];

    return wallet;
  }

  WalletDetails getWallet(String id) {
    final wallet = _wallets.firstWhere((e) => e.id == id);

    return wallet;
  }

  int getWalletIndex(String id) {
    return _wallets.indexWhere((e) => e.id == id);
  }

  int removeWallet(String id) {
    final index = _wallets.indexWhere((e) => e.id == id);
    if (index != -1) {
      _wallets.removeAt(index);
    }

    return index;
  }

  Future<int> getAssetCount(WalletDetails wallet) async {
    var count = _assetCounts[wallet.id];
    if (count == null) {
      final assets = await _assetService.getAssets(wallet.coin, wallet.address);
      count = assets.length;
      _assetCounts[wallet.id] = count;
    }

    return count;
  }

  @override
  FutureOr onDispose() {
    _subscriptions.dispose();
    _count.close();
    _insert.close();
    _updated.close();
    _loading.close();
  }

  Future<void> _onAdded(WalletDetails wallet) async {
    _wallets.add(wallet);
    _insert.tryAdd(_wallets.length - 1);
  }

  void _onUpdated(WalletDetails wallet) {
    final index = _wallets.indexWhere((e) => e.id == wallet.id);
    if (index != -1) {
      _wallets[index] = wallet;
      _assetCounts.remove(wallet.id);
      _updated.add(wallet);
    }
  }

  void _onSelected(WalletDetails? wallet) {
    if (wallet != null) {
      _updated.add(wallet);
    }
  }
}
