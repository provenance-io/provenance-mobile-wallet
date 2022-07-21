import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/wallet_connect_address_helper.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';

class WalletConnectQueueGroup {
  WalletConnectQueueGroup(this.walletAddress, this.clientMeta);

  String walletAddress;
  ClientMeta? clientMeta;
  final Map<String, dynamic> actionLookup = <String, dynamic>{};
}

class WalletConnectQueueService extends Listenable with ListenableMixin {
  final _actionLookup = <String, WalletConnectQueueGroup>{};

  Future<void> createWalletConnectSessionGroup(WalletConnectAddress address,
      String walletAddress, ClientMeta? clientMeta) async {
    _actionLookup.putIfAbsent(address.fullUriString, () {
      return WalletConnectQueueGroup(walletAddress, clientMeta);
    });
  }

  Future<void> removeWalletConnectSessionGroup(
      WalletConnectAddress address) async {
    _actionLookup.remove(address.fullUriString);
    notifyListeners();
  }

  Future<void> updateConnectionDetails(
      WalletConnectAddress address, ClientMeta clientMeta) async {
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }

    group.clientMeta = clientMeta;
  }

  Future<void> addWalletConnectSignRequest(
      WalletConnectAddress address, SignRequest signRequest) async {
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }
    group.actionLookup[signRequest.id] = signRequest;
    notifyListeners();
  }

  Future<void> addWalletConnectSendRequest(
      WalletConnectAddress address, SendRequest sendRequest) async {
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }
    group.actionLookup[sendRequest.id] = sendRequest;
    notifyListeners();
  }

  Future<void> addWalletApproveRequest(WalletConnectAddress address,
      WalletConnectSessionRequestData apporveRequestData) async {
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }
    group.actionLookup[apporveRequestData.id] = apporveRequestData;
    notifyListeners();
  }

  Future<WalletConnectQueueGroup?> loadGroup(
      WalletConnectAddress address) async {
    final group = _actionLookup[address.fullUriString];
    return group;
  }

  Future<dynamic> loadQueuedAction(
      WalletConnectAddress address, String requestId) async {
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }
    final action = group.actionLookup[requestId];
    if (action == null) {
      throw Exception(
          "Unable to locate the queued action with requestId $requestId");
    }
    return action;
  }

  Future<void> removeRequest(
      WalletConnectAddress address, String requestId) async {
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }
    group.actionLookup.remove(requestId);
    notifyListeners();
  }

  Future<List<WalletConnectQueueGroup>> loadAllGroups() async {
    return _actionLookup.values.toList();
  }
}
