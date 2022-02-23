import 'package:provenance_wallet/network/dtos/transaction_dto.dart';

class Transaction {
  Transaction({required TransactionDto dto})
      : assert(dto.address != null),
        assert(dto.feeAmount != null),
        assert(dto.id != null),
        assert(dto.signer != null),
        assert(dto.status != null),
        assert(dto.time != null),
        // assert(dto.type != null),
        address = dto.address!,
        feeAmount = dto.feeAmount!.toString(),
        id = dto.id!,
        signer = dto.signer!,
        status = dto.status!,
        time = dto.time!,
        type = dto.type!;

  Transaction.fake({
    required this.address,
    required this.feeAmount,
    required this.id,
    required this.signer,
    required this.status,
    required this.time,
    required this.type,
  });

  final String address;
  final String feeAmount;
  final String id;
  final String signer;
  final String status;
  final String time;
  final String type;
}
