import 'package:protobuf/protobuf.dart';
import 'package:provenance_dart/proto.dart';

class SendRequest {
  SendRequest({
    required this.id,
    required this.description,
    required this.message,
    required this.gasEstimate,
  });

  final String id;
  final String description;
  final GeneratedMessage message;
  final GasEstimate gasEstimate;
}
