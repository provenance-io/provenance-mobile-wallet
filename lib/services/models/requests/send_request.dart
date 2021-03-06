import 'package:protobuf/protobuf.dart';
import 'package:provenance_dart/proto.dart';

class SendRequest {
  SendRequest({
    required this.id,
    required this.description,
    required this.messages,
    required this.gasEstimate,
  });

  final String id;
  final String description;
  final List<GeneratedMessage> messages;
  final GasEstimate gasEstimate;
}
