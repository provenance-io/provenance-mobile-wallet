import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalVoteConfirmBloc {
  final TransactableAccount _account;
  final Proposal _proposal;
  final gov.VoteOption _voteOption;

  ProposalVoteConfirmBloc(
    this._account,
    this._proposal,
    this._voteOption,
  );

  Future<void> doVote(
    double? gasAdjustment,
  ) async {
    await _sendMessage(
      gasAdjustment,
      gov.MsgVote(
              option: _voteOption,
              proposalId: _proposal.proposalId as Int64,
              voter: _account.address)
          .toAny(),
    );
  }

  Future<void> _sendMessage(
    double? gasAdjustment,
    proto.Any message,
  ) async {
    final body = proto.TxBody(
      messages: [
        message,
      ],
    );

    final privateKey = await get<AccountService>().loadKey(_account.id);

    final adjustedEstimate = await _estimateGas(body);

    AccountGasEstimate estimate = AccountGasEstimate(
      adjustedEstimate.estimate,
      adjustedEstimate.baseFee,
      gasAdjustment ?? adjustedEstimate.feeAdjustment,
      adjustedEstimate.feeCalculated,
    );

    final response = await get<TransactionHandler>().executeTransaction(
      body,
      privateKey!,
      estimate,
    );

    log(response.asJsonString());
  }

  Future<AccountGasEstimate> _estimateGas(proto.TxBody body) async {
    return await (get<TransactionHandler>())
        .estimateGas(body, _account.publicKey);
  }
}

extension VoteOptionExtension on gov.VoteOption {
  String get displayTitle {
    var chunks = name.toLowerCase().replaceAll("vote_", "").split("_");
    var word = "";
    for (var element in chunks) {
      word += element.capitalize();
    }
    return word;
  }
}
