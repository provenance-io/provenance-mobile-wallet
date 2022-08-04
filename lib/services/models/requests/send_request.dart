import 'package:protobuf/protobuf.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';

class SendRequest {
  SendRequest({
    required this.id,
    required this.requestId,
    required this.description,
    required this.messages,
    required this.gasEstimate,
  });

  final String id;
  final int requestId;
  final String description;
  final List<GeneratedMessage> messages;
  final AccountGasEstimate gasEstimate;
}
