import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:provenance_blockchain_wallet/services/transaction_service/dtos/transaction_dto.dart';
import 'package:provenance_blockchain_wallet/util/strings.dart';

class Transaction {
  Transaction({required TransactionDto dto})
      : assert(dto.block != null),
        assert(dto.feeAmount != null),
        assert(dto.hash != null),
        assert(dto.signer != null),
        assert(dto.status != null),
        assert(dto.time != null),
        assert(dto.type != null),
        block = dto.block!,
        feeAmount = dto.feeAmount!,
        hash = dto.hash!,
        signer = dto.signer!,
        status = dto.status!.capitalize(),
        time = dto.time!,
        messageType = dto.type!.capitalize(),
        denom = dto.denom ?? "";

  Transaction.fake({
    required this.block,
    required this.feeAmount,
    required this.hash,
    required this.signer,
    required this.status,
    required this.time,
    required this.messageType,
    required this.denom,
  });

  final int block;
  final String feeAmount;
  final String hash;
  final String signer;
  final String status;
  final DateTime time;
  final String messageType;
  final String denom;

  String get displayDenom {
    return denom.isEmpty
        ? Strings.assetChartNotAvailable
        : 'nhash' == denom
            ? Strings.transactionDenomHash
            : denom.capitalize();
  }

  String get formattedTimestamp {
    return DateFormat('MMM d').format(time);
  }

  String get formattedTime {
    return DateFormat.yMMMd('en_US').add_Hms().format(time);
  }

  String get displayFee {
    // TODO: Consolidate hash conversion somewhere?
    return "${(Decimal.parse(feeAmount) / Decimal.fromInt(10).pow(9)).toDecimal(scaleOnInfinitePrecision: 9).toString()} Hash";
  }
}
