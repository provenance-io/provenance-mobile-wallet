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
    required this.connectAddress,
    required this.accountAddress,
    this.clientMeta,
  });

  final WalletConnectAddress connectAddress;
  final String accountAddress;
  final ClientMeta? clientMeta;
  final actionLookup = <String, WalletConnectAction>{};

  WalletConnectQueueGroup copyWith({
    ClientMeta? clientMeta,
  }) =>
      WalletConnectQueueGroup(
        connectAddress: connectAddress,
        accountAddress: accountAddress,
        clientMeta: clientMeta ?? this.clientMeta,
      );

  static WalletConnectQueueGroup fromRecord(Map<String, dynamic> input) {
    final actions = <String, WalletConnectAction>{};
    input["actions"].entries.forEach((entry) {
      actions[entry.key] = _fromRecord(entry.value);
    });
    final connectAddress =
        WalletConnectAddress.create(input["connectAddress"] as String)!;
    final accountAddress = input["accountAddress"];
    final clientMeta = ClientMeta.fromJson(input["clientMeta"]);

    final group = WalletConnectQueueGroup(
      connectAddress: connectAddress,
      accountAddress: accountAddress,
      clientMeta: clientMeta,
    );
    group.actionLookup.addAll(actions);
    return group;
  }

  Map<String, dynamic> toRecord() {
    final map = <String, dynamic>{
      "connectAddress": connectAddress.fullUriString,
      "accountAddress": accountAddress,
      "clientMeta": clientMeta?.toJson(),
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
          "type": "ApproveSession",
          "id": sessionAction.id,
          "requestId": sessionAction.walletConnectId,
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
          "type": "SendRequest",
          "id": action.id,
          "requestId": action.walletConnectId,
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
          "type": "SignRequest",
          "id": signAction.id,
          "requestId": signAction.walletConnectId,
          "message": signAction.message,
          "description": signAction.description,
          "address": signAction.address
        };
    }
  }

  static WalletConnectAction _fromRecord(Map<String, dynamic> input) {
    final type = input["type"] as String;

    // TODO-Roy: Rename SendRequest to TxAction, SignRequest to SignAction, etc.
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

      return TxAction(
          id: id,
          walletConnectId: requestId,
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

      return SignAction(
          id: id,
          message: message,
          description: description,
          address: address,
          walletConnectId: requestId);
    } else if (type == "ApproveSession") {
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
