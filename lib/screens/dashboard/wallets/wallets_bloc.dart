import 'dart:async';

import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class WalletsBloc {
  WalletsBloc(
    WalletConnectSession? walletSession, {
    required this.loadAllWallets,
    required this.walletMap,
    required this.selectedWallet,
  }) {
    _walletSession = walletSession;
  }

  WalletConnectSession? _walletSession;
  Function loadAllWallets;
  ValueStream<Map<WalletDetails, int>> walletMap;
  ValueStream<WalletDetails?> selectedWallet;

  Future<void> renameWallet({
    required String id,
    String? name,
  }) async {
    if (null == name) {
      return;
    }

    await get<WalletService>().renameWallet(
      id: id,
      name: name,
    );
  }

  Future<void> selectWallet({required String id}) async {
    await _walletSession?.disconnect();
    await get<WalletService>().selectWallet(id: id);
  }

  Future<void> removeWallet(WalletDetails item) async {
    await get<WalletService>().removeWallet(id: item.id);
  }
}
