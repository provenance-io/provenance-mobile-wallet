import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_cosmos_bank_v1beta1.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

extension GeneratedMessageExtension on GeneratedMessage {
  String toLocalizedName(BuildContext context) {
    String name;

    switch (runtimeType) {
      case MsgSend:
        name = Strings.of(context).msgSendName;
        break;
      default:
        name = runtimeType.toString();
    }

    return name;
  }
}
