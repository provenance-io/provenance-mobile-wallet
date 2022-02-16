import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/network/services/asset_service.dart';
import 'package:provenance_wallet/network/services/transaction_service.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/wallet_connect_session.dart';
import 'package:provenance_wallet/services/wallet_connection_service_status.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';

class DashboardBloc extends Disposable {
  DashboardBloc() {
    _initDeepLinks();
  }

  WalletConnectSession? _walletSession;

  final BehaviorSubject<List<Transaction>> _transactionList =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<List<Asset>> _assetList = BehaviorSubject.seeded([]);
  final _sendRequest = PublishSubject<SendRequest>();
  final _signRequest = PublishSubject<SignRequest>();
  final _sessionRequest = PublishSubject<RemoteClientDetails>();
  final _connectionStatus =
      BehaviorSubject.seeded(WalletConnectionServiceStatus.disconnected);

  final _subscriptions = CompositeSubscription();
  final _sessionSubscriptions = CompositeSubscription();

  final _assetService = get<AssetService>();
  final _transactionService = get<TransactionService>();

  ValueStream<List<Transaction>> get transactionList => _transactionList.stream;
  ValueStream<List<Asset>> get assetList => _assetList.stream;
  Stream<SendRequest> get sendRequest => _sendRequest.stream;
  Stream<SignRequest> get signRequest => _signRequest.stream;
  Stream<RemoteClientDetails> get sessionRequest => _sessionRequest.stream;
  ValueStream<WalletConnectionServiceStatus> get connectionStatus =>
      _connectionStatus.stream;

  // TODO: Catch and display errors?
  void load(String walletAddress) async {
    _assetList.value =
        (await _assetService.getAssets(walletAddress)).data ?? [];
    _transactionList.value =
        (await _transactionService.getTransactions(walletAddress)).data ?? [];
  }

  Future<void> connectWallet(String addressData) async {
    final session = await get<WalletService>().connectWallet(addressData);

    if (session != null) {
      session.sendRequest.listen(_sendRequest.add).addTo(_sessionSubscriptions);
      session.signRequest.listen(_signRequest.add).addTo(_sessionSubscriptions);
      session.sessionRequest
          .listen(_sessionRequest.add)
          .addTo(_sessionSubscriptions);
      session.status.listen(_onSessonStatus).addTo(_sessionSubscriptions);
      _walletSession = session;
    }
  }

  Future<bool> disconnectWallet() async {
    final success = await _walletSession?.disconnect() ?? false;

    return success;
  }

  Future<bool> approveSession({
    required String requestId,
    required bool allowed,
  }) async {
    return await _walletSession?.approveSession(
          requestId: requestId,
          allowed: allowed,
        ) ??
        false;
  }

  Future<bool> sendMessageFinish({
    required String requestId,
    required bool allowed,
  }) async {
    return await _walletSession?.sendMessageFinish(
          requestId: requestId,
          allowed: allowed,
        ) ??
        false;
  }

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  }) async {
    return await _walletSession?.signTransactionFinish(
          requestId: requestId,
          allowed: allowed,
        ) ??
        false;
  }

  Future<void> selectWallet({required String id}) async {
    await _walletSession?.disconnect();
    await get<WalletService>().selectWallet(id: id);
  }

  Future<void> renameWallet({
    required String id,
    required String name,
  }) async {
    await get<WalletService>().renameWallet(
      id: id,
      name: name,
    );
  }

  Future<void> removeWallet({required String id}) async {
    await get<WalletService>().removeWallet(id: id);
  }

  Future<void> resetWallets() async {
    await disconnectWallet();
    await get<WalletService>().resetWallets();
  }

  @override
  FutureOr onDispose() {
    _subscriptions.dispose();
    _sessionSubscriptions.dispose();
    _assetList.close();
    _transactionList.close();
    _sendRequest.close();
    _signRequest.close();
    _sessionRequest.close();
    _connectionStatus.close();
    _walletSession?.disconnect();
  }

  Future _initDeepLinks() async {
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      await _handleDynamicLink(initialLink);
    }

    FirebaseDynamicLinks.instance.onLink
        .listen(_handleDynamicLink)
        .addTo(_subscriptions);
  }

  Future<void> _handleDynamicLink(PendingDynamicLinkData linkData) async {
    final path = linkData.link.path;
    switch (path) {
      case '/wallet-connect':
        final data = linkData.link.queryParameters['data'];
        _handleWalletConnectLink(data);
        break;
      default:
        logError('Unhandled dynamic link: $path');
        break;
    }
  }

  Future<void> _handleWalletConnectLink(String? data) async {
    if (data != null) {
      final decodedData = Uri.decodeComponent(data);
      final walletService = get<WalletService>();
      final isValid = await walletService.isValidWalletConnectData(decodedData);
      if (isValid) {
        final walletSession = await walletService.connectWallet(decodedData);
        _walletSession = walletSession;

        if (walletSession == null) {
          logDebug('Wallet connection failed');
        }
      } else {
        logError('Invalid wallet connect data');
      }
    }
  }

  void _onSessonStatus(WalletConnectionServiceStatus status) {
    _connectionStatus.value = status;

    if (status == WalletConnectionServiceStatus.disconnected) {
      _sessionSubscriptions.clear();
    }
  }
}
