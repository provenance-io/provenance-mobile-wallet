import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/wallet_connect_address_helper.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:sembast/sembast.dart';

class WalletConnectQueueGroup {
  static Map<String, dynamic> _toRecord(dynamic input) {
    if (input is SendRequest) {
      final body = TxBody(
        messages: input.messages.map((e) => e.toAny()),
      );

      return <String, dynamic>{
        "type": "SendRequest",
        "id": input.id,
        "message": "",
        "description": input.description,
        "txBody": body.writeToBuffer(),
        "estimate": input.gasEstimate.estimate,
        "feeAdjustment": input.gasEstimate.feeAdjustment,
        "feeCalculated": input.gasEstimate.feeCalculated?.map((e) => e.toAny()),
      };
    } else if (input is SignRequest) {
      return <String, dynamic>{
        "type": "SignRequest",
        "id": input.id,
        "message": input.message,
        "description": input.description,
        "address": input.address
      };
    } else if (input is WalletConnectSessionRequestData) {
      return <String, dynamic>{
        "type": "ApproveSession",
        "id": input.id,
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
      final body = TxBody.fromBuffer(input["txBody"]);
      final id = input["id"];
      final description = input["description"];
      final estimate = input["estimate"];
      final feeAdjustment = input["feeAdjustment"];
      final feeCalculated = input["feeCalculated"]
          ?.cast<Coin>()
          .map((e) => Coin.fromBuffer(e.value));

      return SendRequest(
          id: id,
          description: description,
          messages: body.messages,
          gasEstimate: GasEstimate(estimate, feeAdjustment, feeCalculated));
    } else if (type == "SignRequest") {
      final id = input["id"];
      final description = input["description"];
      final message = input["message"];
      final address = input["address"];

      return SignRequest(
          id: id, message: message, description: description, address: address);
    } else if (type == "ApproveSession") {
      final id = input["id"];
      final peerId = input["peerId"];
      final remotePeerId = input["remotePeerId"];

      return WalletConnectSessionRequestData(
          id,
          SessionRequestData(
              peerId,
              remotePeerId,
              ClientMeta.fromJson(input["clientMeta"]),
              WalletConnectAddress.create(input["address"])!));
    } else {
      throw Exception("${input.runtimeType} is not a supported type");
    }
  }

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
    // final actions = input["actions"]
    //     .map((key, value) => MapEntry(key, _fromRecord(value)));
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
}

class WalletConnectQueueService extends Listenable
    with ListenableMixin
    implements Disposable {
  static const version = 1;
  static const _fileName = ' wallet_connect_queue.db';

  final _actionLookup = <String, WalletConnectQueueGroup>{};
  late final StoreRef<String, dynamic> _main;
  final DatabaseFactory _factory;
  late final Future<Database> _db;

  WalletConnectQueueService({
    required DatabaseFactory factory,
    required String directory,
    Map<dynamic, dynamic>? import,
  }) : _factory = factory {
    final path = p.join(directory, _fileName);

    Future<Database> initDb(
        DatabaseFactory factory, Map<dynamic, dynamic>? import) async {
      Future<void> onVersionChanged(
          Database db, int oldVersion, int newVersion) async {}

      _main = StoreRef<String, dynamic>.main();

      final db = await factory.openDatabase(
        path,
        version: version,
        onVersionChanged: onVersionChanged,
      );

      return db;
    }

    _db = initDb(factory, import);
  }

  Future<void> close() async {
    final db = await _db;
    await db.close();
  }

  Future<void> createWalletConnectSessionGroup(WalletConnectAddress address,
      String walletAddress, ClientMeta? clientMeta) async {
    // _actionLookup.putIfAbsent(address.fullUriString, () {
    //   return WalletConnectQueueGroup(walletAddress, clientMeta);
    // });
    /*
    final finder = Finder(
      filter: Filter.equals("WcAddress", address.fullUriString)
    );

    final db = await _db;
    final record = await _main.findFirst(db,finder: finder);

    if(record == null) {
      await _main.add(db, <String,dynamic> {
        "wcAddress": address.fullUriString,
        "walletAddress": walletAddress,
        "clientMeta": clientMeta?.toJson(), 
        "actions": <Map<String,dynamic>>[]
      });
    }
    */

    final db = await _db;
    final group = WalletConnectQueueGroup(walletAddress, clientMeta);

    final record = _main.record(address.fullUriString);

    record.add(db, group.toRecord());
  }

  Future<void> removeWalletConnectSessionGroup(
      WalletConnectAddress address) async {
    // _actionLookup.remove(address.fullUriString);
/*
    final finder =
        Finder(filter: Filter.equals("WcAddress", address.fullUriString));
    
    final db = await _db;
    int deletedCount = await _main.delete(db, finder: finder);
    log("$deletedCount deleted records");
*/
    final db = await _db;
    final record = _main.record(address.fullUriString);
    await record.delete(db);
    notifyListeners();
  }

  Future<void> updateConnectionDetails(
      WalletConnectAddress address, ClientMeta clientMeta) async {
    /*
    final finder =
        Finder(filter: Filter.equals("WcAddress", address.fullUriString));

    final db = await _db;
    final record = await _main.findFirst(db, finder: finder);

    if (record == null) {
      throw Exception("Unable to locate the connection details");
    }
    
    final map = record.value as Map<String,dynamic>;
    map["clientMeta"] = clientMeta.toJson();
  
    _main.update(db, value)
    */

    final db = await _db;
    final record = _main.record(address.fullUriString);
    final map = await record.get(db);
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.updateClientMeta(clientMeta);

    await record.update(db, group.toRecord());
    // final group = _actionLookup[address.fullUriString];
    // if (group == null) {
    //   throw Exception("Unable to locate the connection details");
    // }

    // group.clientMeta = clientMeta;
  }

  Future<void> addWalletConnectSignRequest(
      WalletConnectAddress address, SignRequest signRequest) async {
    /*
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }
    group.actionLookup[signRequest.id] = signRequest;
    */

    final db = await _db;
    final record = _main.record(address.fullUriString);
    final map = await record.get(db);
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[signRequest.id] = signRequest;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<void> addWalletConnectSendRequest(
      WalletConnectAddress address, SendRequest sendRequest) async {
    /*
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }
    group.actionLookup[sendRequest.id] = sendRequest;
    notifyListeners();*/

    final db = await _db;
    final record = _main.record(address.fullUriString);
    final map = await record.get(db);
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[sendRequest.id] = sendRequest;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<void> addWalletApproveRequest(WalletConnectAddress address,
      WalletConnectSessionRequestData apporveRequestData) async {
    /*
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }
    group.actionLookup[apporveRequestData.id] = apporveRequestData;
    notifyListeners();
    */

    final db = await _db;
    final record = _main.record(address.fullUriString);
    final map = await record.get(db);
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[apporveRequestData.id] = apporveRequestData;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<WalletConnectQueueGroup?> loadGroup(
      WalletConnectAddress address) async {
    final db = await _db;
    final record = _main.record(address.fullUriString);
    final map = await record.get(db);
    return WalletConnectQueueGroup.fromRecord(map);
  }

  Future<dynamic> loadQueuedAction(
      WalletConnectAddress address, String requestId) async {
    /*
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
    */

    final db = await _db;
    final record = _main.record(address.fullUriString);
    final map = await record.get(db);
    final group = WalletConnectQueueGroup.fromRecord(map);
    return group.actionLookup[requestId];
  }

  Future<void> removeRequest(
      WalletConnectAddress address, String requestId) async {
    /*
    final group = _actionLookup[address.fullUriString];
    if (group == null) {
      throw Exception("Unable to locate the connection details");
    }
    group.actionLookup.remove(requestId);
    notifyListeners();
    */

    final db = await _db;
    final record = _main.record(address.fullUriString);
    final map = await record.get(db);
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup.remove(requestId);

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<List<WalletConnectQueueGroup>> loadAllGroups() async {
    // return _actionLookup.values.toList();

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
