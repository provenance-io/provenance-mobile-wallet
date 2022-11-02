import 'package:protobuf/protobuf.dart';
import 'package:provenance_wallet/gas_fee_estimate.dart';

import 'wallet_connect_action.dart';
import 'wallet_connect_action_kind.dart';

class TxAction implements WalletConnectAction {
  TxAction({
    required this.id,
    required this.walletConnectRequestId,
    required this.description,
    required this.messages,
    required this.gasEstimate,
  });

  @override
  final String id;

  @override
  final int walletConnectRequestId;

  @override
  WalletConnectActionKind get kind => WalletConnectActionKind.tx;

  final String description;
  final List<GeneratedMessage> messages;
  final GasFeeEstimate gasEstimate;
}
