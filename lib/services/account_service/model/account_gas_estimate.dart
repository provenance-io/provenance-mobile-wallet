import 'package:provenance_dart/proto.dart';
import 'package:provenance_wallet/util/fee_util.dart';

// TODO-Roy: Remove this class in favor of proto.Fee
class AccountGasEstimate {
  AccountGasEstimate(
    this.estimatedGas, [
    this.baseFee,
    this.gasAdjustment,
    this.estimatedFees,
  ]) : totalFees = addBaseFee(estimatedGas, estimatedFees, baseFee);

  final int? baseFee;
  final int estimatedGas;
  final double? gasAdjustment;
  final List<Coin>? estimatedFees;
  final List<Coin> totalFees;
}
