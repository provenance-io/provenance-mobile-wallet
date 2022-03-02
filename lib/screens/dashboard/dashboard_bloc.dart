import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/wallet_connect_session.dart';
import 'package:provenance_wallet/services/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/services/wallet_connection_service_status.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';

class DashboardBloc extends Disposable {
  DashboardBloc() {
    _initDeepLinks();
  }

  WalletConnectSession? _walletSession;

  final BehaviorSubject<List<Transaction>> _transactionList =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<Map<WalletDetails, int>> _walletMap =
      BehaviorSubject.seeded({});
  final BehaviorSubject<List<Asset>> _assetList = BehaviorSubject.seeded([]);
  final _sendRequest = PublishSubject<SendRequest>();
  final _signRequest = PublishSubject<SignRequest>();
  final _sessionRequest = PublishSubject<RemoteClientDetails>();
  final _clientDetails = BehaviorSubject<RemoteClientDetails?>.seeded(null);
  final _connectionStatus =
      BehaviorSubject.seeded(WalletConnectionServiceStatus.disconnected);
  final BehaviorSubject<String?> _address = BehaviorSubject.seeded(null);
  final _error = PublishSubject<String>();
  final _response = PublishSubject<WalletConnectTxResponse>();
  final BehaviorSubject<WalletDetails?> _selectedWallet =
      BehaviorSubject.seeded(null);

  final _subscriptions = CompositeSubscription();
  final _sessionSubscriptions = CompositeSubscription();

  final _assetService = get<AssetService>();
  final _transactionService = get<TransactionService>();

  ValueStream<List<Transaction>> get transactionList => _transactionList;
  ValueStream<List<Asset>> get assetList => _assetList;
  Stream<SendRequest> get sendRequest => _sendRequest;
  Stream<SignRequest> get signRequest => _signRequest;
  Stream<RemoteClientDetails> get sessionRequest => _sessionRequest;
  ValueStream<RemoteClientDetails?> get clientDetails => _clientDetails;
  ValueStream<WalletConnectionServiceStatus> get connectionStatus =>
      _connectionStatus.stream;
  ValueStream<String?> get address => _address.stream;
  ValueStream<WalletDetails?> get selectedWallet => _selectedWallet.stream;
  ValueStream<Map<WalletDetails, int>> get walletMap => _walletMap;
  Stream<String> get error => _error;
  Stream<WalletConnectTxResponse> get response => _response;

  void load(BuildContext context) async {
    var details = await get<WalletService>().getSelectedWallet();
    _selectedWallet.value = details;
    var errorCount = 0;
    try {
      _assetList.value =
          (await _assetService.getAssets(details?.address ?? ""));
    } catch (e) {
      errorCount++;
    }

    try {
      _transactionList.value =
          (await _transactionService.getTransactions(details?.address ?? ""));
    } catch (e) {
      errorCount++;
      if (errorCount == 2) {
        showDialog(
          useSafeArea: true,
          context: context,
          builder: (context) => ErrorDialog(
            title: Strings.serviceErrorTitle,
            error: Strings.theSystemIsDown,
            buttonText: Strings.continueName,
          ),
        );
      }
    }
  }

  Future<void> connectWallet(String addressData) async {
    final session = await get<WalletService>().connectWallet(addressData);

    if (session != null) {
      session.sendRequest.listen(_sendRequest.add).addTo(_sessionSubscriptions);
      session.signRequest.listen(_signRequest.add).addTo(_sessionSubscriptions);
      session.sessionRequest
          .listen(_sessionRequest.add)
          .addTo(_sessionSubscriptions);
      session.clientDetails
          .listen(_clientDetails.add)
          .addTo(_sessionSubscriptions);
      session.status.listen(_onSessionStatus).addTo(_sessionSubscriptions);
      session.address.listen(_onAddress).addTo(_sessionSubscriptions);
      session.error.listen(_error.add).addTo(_sessionSubscriptions);
      session.response.listen(_response.add).addTo(_sessionSubscriptions);
      _walletSession = session;
    }
  }

  Future<bool> disconnectWallet() async {
    final success = await _walletSession?.disconnect() ?? false;

    return success;
  }

  Future<bool> approveSession({
    required RemoteClientDetails details,
    required bool allowed,
  }) async {
    return await _walletSession?.approveSession(
          details: details,
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

  Future<bool> isValidWalletConnectAddress(String address) {
    return get<WalletService>().isValidWalletConnectData(address);
  }

  Future<void> removeWallet({required String id}) async {
    await get<WalletService>().removeWallet(id: id);
  }

  Future<void> resetWallets() async {
    await disconnectWallet();
    await get<WalletService>().resetWallets();
  }

  Future<void> loadAllWallets() async {
    var list = (await get<WalletService>().getWallets());
    list.sort((a, b) {
      if (b.address == selectedWallet.value?.address) {
        return 1;
      } else if (a.address == selectedWallet.value?.address) {
        return -1;
      } else {
        return 0;
      }
    });

    Map<WalletDetails, int> map = {};

    for (var wallet in list) {
      var assets = wallet.address == selectedWallet.value?.address
          ? assetList.value
          : (await _assetService.getAssets(wallet.address));
      map[wallet] = assets.length;
    }

    _walletMap.value = map;
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
    _clientDetails.close();
    _connectionStatus.close();
    _error.close();
    _response.close();
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

  void _onAddress(String? address) {
    _address.value = address;

    if (WalletConnectionServiceStatus.disconnected == _connectionStatus.value) {
      _sessionSubscriptions.clear();
    }
  }

  void _onSessionStatus(WalletConnectionServiceStatus status) {
    _connectionStatus.value = status;

    if (status == WalletConnectionServiceStatus.disconnected) {
      _sessionSubscriptions.clear();
    }
  }
}
