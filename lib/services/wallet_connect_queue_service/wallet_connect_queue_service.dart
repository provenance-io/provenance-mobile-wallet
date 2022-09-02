import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/wallet_connect_address_helper.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:sembast/sembast.dart';

class WalletConnectQueueGroup {
  WalletConnectQueueGroup(this.walletAddress, this.clientMeta);

  String walletAddress;
  ClientMeta? clientMeta;
  final Map<String, dynamic> actionLookup = <String, dynamic>{};

  void updateClientMeta(ClientMeta meta) {
    clientMeta = meta;
  }

  static WalletConnectQueueGroup fromRecord(Map<String, dynamic> input) {
    final actions = <String, dynamic>{};
    input["actions"].entries.forEach((entry) {
      actions[entry.key] = _fromRecord(entry.value);
    });
    final walletAddress = input["walletAddress"];
    final clientMeta = ClientMeta.fromJson(input["clientMeta"]);

    final group = WalletConnectQueueGroup(walletAddress, clientMeta);
    group.actionLookup.addAll(actions);
    return group;
  }

  Map<String, dynamic> toRecord() {
    final map = <String, dynamic>{
      "walletAddress": walletAddress,
      "clientMeta": clientMeta?.toJson(),
      "actions":
          actionLookup.map((key, value) => MapEntry(key, _toRecord(value)))
    };

    return map;
  }

  static Map<String, dynamic> _toRecord(dynamic input) {
    if (input is SendRequest) {
      final body = TxBody(
        messages: input.messages.map((e) => e.toAny()),
      );

      return <String, dynamic>{
        "type": "SendRequest",
        "id": input.id,
        "requestId": input.requestId,
        "message": "",
        "description": input.description,
        "txBody": body.writeToBuffer(),
        "estimate": input.gasEstimate.estimatedGas,
        "baseFee": input.gasEstimate.baseFee,
        "feeAdjustment": input.gasEstimate.gasAdjustment,
        "feeCalculated":
            input.gasEstimate.totalFees.map((e) => e.writeToBuffer()).toList(),
      };
    } else if (input is SignRequest) {
      return <String, dynamic>{
        "type": "SignRequest",
        "id": input.id,
        "requestId": input.requestId,
        "message": input.message,
        "description": input.description,
        "address": input.address
      };
    } else if (input is WalletConnectSessionRequestData) {
      return <String, dynamic>{
        "type": "ApproveSession",
        "id": input.id,
        "requestId": input.requestId,
        "message": "Approval required",
        "description": "",
        "address": input.data.address.fullUriString,
        "clientMeta": input.data.clientMeta.toJson(),
        "peerId": input.data.peerId,
        "remotePeerId": input.data.remotePeerId,
      };
    } else {
      throw Exception("${input.runtimeType} is not a supported type");
    }
  }

  static dynamic _fromRecord(Map<String, dynamic> input) {
    final type = input["type"] as String;

    if (type == "SendRequest") {
      final body = TxBody.fromBuffer(input["txBody"].cast<int>());
      final id = input["id"];
      final requestId = input["requestId"];
      final description = input["description"];
      final estimate = input["estimate"];
      final feeAdjustment = input["feeAdjustment"];
      final baseFee = input["baseFee"];
      final feeCalculated = input["feeCalculated"]
          ?.map((e) => Coin.fromBuffer(e.cast<int>()))
          .cast<Coin>()
          .toList();

      return SendRequest(
          id: id,
          requestId: requestId,
          description: description,
          messages: body.messages
              .map((e) => e.toMessage())
              .toList()
              .cast<GeneratedMessage>(),
          gasEstimate: AccountGasEstimate(
              estimate, baseFee, feeAdjustment, feeCalculated));
    } else if (type == "SignRequest") {
      final id = input["id"];
      final requestId = input["requestId"];
      final description = input["description"];
      final message = input["message"];
      final address = input["address"];

      return SignRequest(
          id: id,
          message: message,
          description: description,
          address: address,
          requestId: requestId);
    } else if (type == "ApproveSession") {
      final id = input["id"];
      final requestId = input["requestId"];
      final peerId = input["peerId"];
      final remotePeerId = input["remotePeerId"];

      return WalletConnectSessionRequestData(
          id,
          requestId,
          SessionRequestData(
              peerId,
              remotePeerId,
              ClientMeta.fromJson(input["clientMeta"]),
              WalletConnectAddress.create(input["address"])!));
    } else {
      throw Exception("${input.runtimeType} is not a supported type");
    }
  }
}

class WalletConnectQueueService extends Listenable
    with ListenableMixin
    implements Disposable {
  static const version = 1;
  static const fileName = 'wallet_connect_queue.db';

  final DatabaseFactory _factory;
  final StoreRef<String, Map<String, dynamic>> _main =
      StoreRef<String, Map<String, dynamic>>.main();

  late final Future<Database> _db;

  WalletConnectQueueService({
    required DatabaseFactory factory,
    required String directory,
    Map<dynamic, dynamic>? import,
  }) : _factory = factory {
    final path = p.join(directory, fileName);
    _db = _initDb(path, factory, import);
  }

  Future<Database> _initDb(String dbPath, DatabaseFactory factory,
      Map<dynamic, dynamic>? import) async {
    final db = await _factory.openDatabase(
      dbPath,
      version: version,
      onVersionChanged: _onVersionChanced,
    );

    return db;
  }

  Future<void> _onVersionChanced(
      Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    final db = await _db;
    await db.close();
  }

  Future<void> createWalletConnectSessionGroup(WalletConnectAddress address,
      String walletAddress, ClientMeta? clientMeta) async {
    final group = WalletConnectQueueGroup(walletAddress, clientMeta);
    final record = _main.record(address.fullUriString);

    final db = await _db;

    await record.add(db, group.toRecord());
  }

  Future<void> removeWalletConnectSessionGroup(
      WalletConnectAddress address) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    await record.delete(db);
    notifyListeners();
  }

  Future<void> updateConnectionDetails(
      WalletConnectAddress address, ClientMeta clientMeta) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);

    if (map == null) {
      return;
    }

    final group = WalletConnectQueueGroup.fromRecord(map);
    group.updateClientMeta(clientMeta);

    await record.update(db, group.toRecord());
  }

  Future<void> addWalletConnectSignRequest(
      WalletConnectAddress address, SignRequest signRequest) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }

    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[signRequest.id] = signRequest;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<void> addWalletConnectSendRequest(
      WalletConnectAddress address, SendRequest sendRequest) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }

    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[sendRequest.id] = sendRequest;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<void> addWalletApproveRequest(WalletConnectAddress address,
      WalletConnectSessionRequestData approveRequestData) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[approveRequestData.id] = approveRequestData;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<WalletConnectQueueGroup?> loadGroup(
      WalletConnectAddress address) async {
    final db = await _db;
    final record = _main.record(address.fullUriString);
    final map = await record.get(db);
    if (map == null) {
      return null;
    }
    return WalletConnectQueueGroup.fromRecord(map);
  }

  Future<dynamic> loadQueuedAction(
      WalletConnectAddress address, String requestId) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return null;
    }
    final group = WalletConnectQueueGroup.fromRecord(map);
    return group.actionLookup[requestId];
  }

  Future<void> removeRequest(
      WalletConnectAddress address, String requestId) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup.remove(requestId);

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<List<WalletConnectQueueGroup>> loadAllGroups() async {
    final db = await _db;
    final values = await _main.find(db);

    return values
        .map((e) => WalletConnectQueueGroup.fromRecord(e.value))
        .toList();
  }

  @override
  FutureOr onDispose() {
    return close();
  }
}
