import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:provenance_wallet/services/transaction_client/dtos/send_transaction_dto.dart';

class SendTransaction {
  SendTransaction({required SendTransactionDto dto})
      : assert(dto.amount != null),
        assert(dto.block != null),
        assert(dto.denom != null),
        assert(dto.hash != null),
        assert(dto.recipientAddress != null),
        assert(dto.senderAddress != null),
        assert(dto.timestamp != null),
        assert(dto.status != null),
        assert(dto.txFee != null),
        assert(dto.pricePerUnit != null),
        assert(dto.totalPrice != null),
        assert(dto.exponent != null),
        amount = dto.amount!,
        block = dto.block!,
        denom = dto.denom!,
        hash = dto.hash!,
        recipientAddress = dto.recipientAddress!,
        senderAddress = dto.senderAddress!,
        status = dto.status!,
        timestamp = dto.timestamp!,
        txFee = dto.txFee!,
        pricePerUnit = dto.pricePerUnit!,
        totalPrice = dto.totalPrice!,
        exponent = dto.exponent!;

  SendTransaction.fake({
    required this.amount,
    required this.block,
    required this.denom,
    required this.hash,
    required this.recipientAddress,
    required this.senderAddress,
    required this.status,
    required this.timestamp,
    required this.txFee,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.exponent,
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
  final double pricePerUnit;
  final double totalPrice;
  final int exponent;

  String get displayAmount {
    return (Decimal.fromInt(amount) / Decimal.fromInt(10).pow(exponent))
        .toDecimal(scaleOnInfinitePrecision: exponent)
        .toString();
  }

  String get formattedTimestamp {
    return DateFormat('MMM d').format(timestamp);
  }
}
