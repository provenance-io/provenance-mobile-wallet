import 'package:provenance_dart/proto.dart' as proto;

class SembastGasEstimate {
  SembastGasEstimate({
    required this.estimatedGas,
    this.baseFee,
    this.gasAdjustment,
    this.estimatedFees,
  });

  final int estimatedGas;
  final int? baseFee;
  final double? gasAdjustment;
  final List<proto.Coin>? estimatedFees;

  Map<String, Object?> toRecord() => {
        'estimatedGas': estimatedGas,
        if (baseFee != null) 'baseFee': baseFee,
        if (gasAdjustment != null) 'gasAdjustment': gasAdjustment,
        if (estimatedFees != null)
          'estimatedFees': estimatedFees?.map((e) => e.writeToJson()).toList(),
      };

  factory SembastGasEstimate.fromRecord(Map<String, Object?> rec) =>
      SembastGasEstimate(
        estimatedGas: rec['estimatedGas'] as int,
        baseFee: rec['baseFee'] as int?,
        gasAdjustment: rec['gasAdjustment'] as double?,
        estimatedFees: (rec['estimatedFees'] as List<String>?)
            ?.map((e) => proto.Coin.fromJson(e))
            .toList(),
      );
}
