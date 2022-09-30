import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/extension/wallet_connect_address_helper.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/session_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/sign_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/tx_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_action_kind.dart';

class WalletConnectQueueGroup {
  WalletConnectQueueGroup({
    required this.accountId,
    this.clientMeta,
  });

  final String accountId;
  final ClientMeta? clientMeta;
  final actionLookup = <String, WalletConnectAction>{};

  WalletConnectQueueGroup copyWith({
    ClientMeta? clientMeta,
  }) =>
      WalletConnectQueueGroup(
        accountId: accountId,
        clientMeta: clientMeta ?? this.clientMeta,
      );

  static WalletConnectQueueGroup fromRecord(Map<String, dynamic> input) {
    final actions = <String, WalletConnectAction>{};
    input["actions"].entries.forEach((entry) {
      actions[entry.key] = _fromRecord(entry.value);
    });

    final group = WalletConnectQueueGroup(
      accountId: input['accountId'] as String,
      clientMeta: input.containsKey('clientMeta')
          ? ClientMeta.fromJson(input['clientMeta'])
          : null,
    );
    group.actionLookup.addAll(actions);
    return group;
  }

  Map<String, dynamic> toRecord() {
    final map = <String, dynamic>{
      'accountId': accountId,
      if (clientMeta != null) "clientMeta": clientMeta?.toJson(),
      "actions":
          actionLookup.map((key, value) => MapEntry(key, _toRecord(value)))
    };

    return map;
  }

  static Map<String, dynamic> _toRecord(WalletConnectAction action) {
    switch (action.kind) {
      case WalletConnectActionKind.session:
        final sessionAction = action as SessionAction;

        return <String, dynamic>{
          "type": "SessionAction",
          "id": sessionAction.id,
          "requestId": sessionAction.walletConnectRequestId,
          "message": "Approval required",
          "description": "",
          "address": sessionAction.data.address.fullUriString,
          "clientMeta": sessionAction.data.clientMeta.toJson(),
          "peerId": sessionAction.data.peerId,
          "remotePeerId": sessionAction.data.remotePeerId,
        };
      case WalletConnectActionKind.tx:
        final txAction = action as TxAction;

        final body = TxBody(
          messages: txAction.messages.map((e) => e.toAny()),
        );

        return <String, dynamic>{
          "type": "TxAction",
          "id": action.id,
          "requestId": action.walletConnectRequestId,
          "message": "",
          "description": txAction.description,
          "txBody": body.writeToBuffer(),
          "estimate": txAction.gasEstimate.estimatedGas,
          "baseFee": txAction.gasEstimate.baseFee,
          "feeAdjustment": txAction.gasEstimate.gasAdjustment,
          "feeCalculated": txAction.gasEstimate.totalFees
              .map((e) => e.writeToBuffer())
              .toList(),
        };
      case WalletConnectActionKind.sign:
        final signAction = action as SignAction;

        return <String, dynamic>{
          "type": "SignAction",
          "id": signAction.id,
          "requestId": signAction.walletConnectRequestId,
          "message": signAction.message,
          "description": signAction.description,
          "address": signAction.address
        };
    }
  }

  static WalletConnectAction _fromRecord(Map<String, dynamic> input) {
    final type = input["type"] as String;

    if (type == "TxAction") {
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

      return TxAction(
          id: id,
          walletConnectRequestId: requestId,
          description: description,
          messages: body.messages
              .map((e) => e.toMessage())
              .toList()
              .cast<GeneratedMessage>(),
          gasEstimate: AccountGasEstimate(
              estimate, baseFee, feeAdjustment, feeCalculated));
    } else if (type == "SignAction") {
      final id = input["id"];
      final requestId = input["requestId"];
      final description = input["description"];
      final message = input["message"];
      final address = input["address"];

      return SignAction(
          id: id,
          message: message,
          description: description,
          address: address,
          walletConnectRequestId: requestId);
    } else if (type == "SessionAction") {
      final id = input["id"];
      final requestId = input["requestId"];
      final peerId = input["peerId"];
      final remotePeerId = input["remotePeerId"];

      return SessionAction(
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
