import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/type_registry.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

abstract class TransactionBloc<T extends proto.GeneratedMessage>
    implements Disposable {
  TransactionBloc(
    this.account,
  );

  final TransactableAccount account;

  Future<Object?> sendTransaction(
    double? gasAdjustment,
  ) async {
    return await _sendMessage(
      gasAdjustment,
      getMessage().toAny(),
    );
  }

  Object? getMessageJson() {
    return getMessage().toProto3Json(typeRegistry: provenanceTypes);
  }

  T getMessage();

  Future<Object?> _sendMessage(
    double? gasAdjustment,
    proto.Any message,
  ) async {
    final body = proto.TxBody(
      messages: [
        message,
      ],
    );

    final privateKey = await get<AccountService>().loadKey(account.id);

    final adjustedEstimate = await _estimateGas(body);

    AccountGasEstimate estimate = AccountGasEstimate(
      adjustedEstimate.estimatedGas,
      adjustedEstimate.baseFee,
      gasAdjustment ?? adjustedEstimate.gasAdjustment,
      adjustedEstimate.totalFees,
    );

    final response = await get<TransactionHandler>().executeTransaction(
      body,
      privateKey!.defaultKey(),
      account.coin,
      estimate,
    );

    log(response.asJsonString());
    return response.txResponse.toProto3Json(typeRegistry: provenanceTypes);
  }

  Future<AccountGasEstimate> _estimateGas(proto.TxBody body) async {
    return await (get<TransactionHandler>()).estimateGas(
      body,
      [account.publicKey],
      account.coin,
    );
  }
}
