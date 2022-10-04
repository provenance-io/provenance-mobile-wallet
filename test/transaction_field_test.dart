import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank_v1beta1.dart';
import 'package:provenance_dart/proto_marker_v1.dart';
import 'package:provenance_dart/type_registry.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/messages/message_field.dart';
import 'package:provenance_wallet/util/messages/message_field_group.dart';
import 'package:provenance_wallet/util/messages/message_field_processor.dart';

final msgSend = MsgSend(
  fromAddress: 'abcdefghijklmnop',
  toAddress: 'abcdefghijklmnop',
  amount: [
    Coin(
      denom: nHashDenom,
      amount: '1000000000',
    ),
  ],
);

final msgAddMarker = MsgAddMarkerRequest(
  amount: Coin(
    denom: nHashDenom,
    amount: '100000000',
  ),
  manager: 'abcdefghijklmnop',
  fromAddress: 'abcdefghijklmnop',
  status: MarkerStatus.MARKER_STATUS_ACTIVE,
  markerType: MarkerType.MARKER_TYPE_COIN,
  accessList: [
    AccessGrant(
      address: 'abcdefghijklmnop',
      permissions: [
        Access.ACCESS_BURN,
        Access.ACCESS_DELETE,
      ],
    ),
  ],
  supplyFixed: true,
  allowGovernanceControl: true,
);

final messages = [
  msgSend,
  msgAddMarker,
];

const address = 'abcdefghijklmnop';

final processor = MessageFieldProcessor(
  transactionFieldTrue: "Yes",
  transactionFieldFalse: "No",
);

void main() {
  test('Finds address', () {
    final send = MsgSend(
      fromAddress: address,
    );
    final json = send.toProto3Json(typeRegistry: provenanceTypes)
        as Map<String, dynamic>;

    final group = processor.findFields(json);
    expect(group.fields[0] is MessageField, isTrue);

    final field = group.fields[0] as MessageField;
    expect(field.value, address);
  });

  test('Finds amount', () {
    const amount = '1000000000';

    final send = MsgSend(
      amount: [
        Coin(
          amount: amount,
          denom: nHashDenom,
        ),
      ],
    );
    final json = send.toProto3Json(typeRegistry: provenanceTypes)
        as Map<String, dynamic>;
    final group = processor.findFields(json);
    expect(group.fields[0] is MessageFieldGroup, isTrue);

    final amountGroup = group.fields[0] as MessageFieldGroup;
    expect(amountGroup.fields[0] is MessageField, isTrue);

    final denomField = amountGroup.fields[0] as MessageField;
    expect(denomField.value, nHashDenom);

    final amountField = amountGroup.fields[1] as MessageField;
    expect(amountField.value, amount);
  });
}
