import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/extension/wallet_connect_address_helper.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';

class WalletConnectQueueGroup {
  WalletConnectQueueGroup({
    required this.walletAddress,
    this.clientMeta,
  });

  final String walletAddress;
  final ClientMeta? clientMeta;
  final Map<String, dynamic> actionLookup = <String, dynamic>{};

  WalletConnectQueueGroup copyWith({
    ClientMeta? clientMeta,
  }) =>
      WalletConnectQueueGroup(
        walletAddress: walletAddress,
        clientMeta: clientMeta ?? this.clientMeta,
      );

  static WalletConnectQueueGroup fromRecord(Map<String, dynamic> input) {
    final actions = <String, dynamic>{};
    input["actions"].entries.forEach((entry) {
      actions[entry.key] = _fromRecord(entry.value);
    });
    final walletAddress = input["walletAddress"];
    final clientMeta = ClientMeta.fromJson(input["clientMeta"]);

    final group = WalletConnectQueueGroup(
      walletAddress: walletAddress,
      clientMeta: clientMeta,
    );
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
