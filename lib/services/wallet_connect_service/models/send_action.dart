import 'package:protobuf/protobuf.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';

import 'wallet_connect_action.dart';
import 'wallet_connect_action_kind.dart';

class SendAction implements WalletConnectAction {
  SendAction({
    required this.id,
    required this.requestId,
    required this.description,
    required this.messages,
    required this.gasEstimate,
  });

  @override
  final String id;

  @override
  final int requestId;

  @override
  WalletConnectActionKind get kind => WalletConnectActionKind.send;

  final String description;
  final List<GeneratedMessage> messages;
  final AccountGasEstimate gasEstimate;
}
