import 'package:provenance_wallet/services/transaction_service/dtos/transaction_dto.dart';

class Transaction {
  Transaction({required TransactionDto dto})
      : assert(dto.amount != null),
        assert(dto.block != null),
        assert(dto.denom != null),
        assert(dto.hash != null),
        assert(dto.recipientAddress != null),
        assert(dto.senderAddress != null),
        assert(dto.timestamp != null),
        assert(dto.status != null),
        assert(dto.txFee != null),
        amount = dto.amount!,
        block = dto.block!,
        denom = dto.denom!,
        hash = dto.hash!,
        recipientAddress = dto.recipientAddress!,
        senderAddress = dto.senderAddress!,
        status = dto.status!,
        timestamp = dto.timestamp!,
        txFee = dto.txFee!;

  Transaction.fake({
    required this.amount,
    required this.block,
    required this.denom,
    required this.hash,
    required this.recipientAddress,
    required this.senderAddress,
    required this.status,
    required this.timestamp,
    required this.txFee,
  });

  final int amount;
  final int block;
  final String denom;
  final String hash;
  final String recipientAddress;
  final String senderAddress;
  final String status;
  final DateTime timestamp;
  final int txFee;
}
