import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class WalletsBloc implements Disposable {
  WalletsBloc() {
    _walletService.events.added.listen(_onAdded);
    _walletService.events.removed.listen(_onRemoved);
  }

  final _subscriptions = CompositeSubscription();
  final _walletService = get<WalletService>();
  final _assetService = get<AssetService>();
  final _count = BehaviorSubject.seeded(0);
  final _removed = PublishSubject<WalletDataChange>();
  final _insert = PublishSubject<int>();
  final _loading = BehaviorSubject.seeded(false);

  Completer? _completer;
  var _wallets = <WalletDetails>[];
  final _assetCounts = <String, int>{};

  ValueStream<int> get count => _count;
  Stream<WalletDataChange> get removed => _removed;
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

  WalletDetails getWallet(int index) {
    final wallet = _wallets[index];

    return wallet;
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
    _removed.close();
    _insert.close();
    _loading.close();
  }

  Future<void> _onAdded(WalletDetails wallet) async {
    _wallets.add(wallet);
    _insert.tryAdd(_wallets.length - 1);
  }

  void _onRemoved(List<WalletDetails> wallets) {
    for (final wallet in wallets) {
      final index = _wallets.indexWhere((e) => e.id == wallet.id);
      if (index != -1) {
        final data = _wallets.removeAt(index);

        _removed.tryAdd(WalletDataChange(index, data));
      }
    }
  }
}

class WalletDataChange {
  WalletDataChange(this.index, this.details);

  final int index;
  final WalletDetails details;
}
