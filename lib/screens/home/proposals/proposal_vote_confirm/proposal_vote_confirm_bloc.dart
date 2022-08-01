import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

class ProposalVoteConfirmBloc {
  final Account _account;
  final Proposal _proposal;
  final gov.VoteOption _voteOption;

  ProposalVoteConfirmBloc(
    this._account,
    this._proposal,
    this._voteOption,
  );

  Future<Object?> doVote(
    double? gasAdjustment,
  ) async {
    return await _sendMessage(
      gasAdjustment,
      _getMsgVote().toAny(),
    );
  }

  Object? getMsgVoteJson() {
    return _getMsgVote().toProto3Json();
  }

  gov.MsgVote _getMsgVote() {
    return gov.MsgVote(
      option: _voteOption,
      proposalId: Int64.parseInt(_proposal.proposalId.toString()),
      voter: _account.publicKey!.address,
    );
  }

  Future<Object?> _sendMessage(
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
    return response.txResponse.toProto3Json();
  }

  Future<AccountGasEstimate> _estimateGas(proto.TxBody body) async {
    return await (get<TransactionHandler>())
        .estimateGas(body, _account.publicKey!);
  }

  Vote getUserFriendlyVote() {
    switch (_voteOption) {
      case gov.VoteOption.VOTE_OPTION_ABSTAIN:
        return Vote.demo(answerAbstain: 1);
      case gov.VoteOption.VOTE_OPTION_NO:
        return Vote.demo(answerNo: 1);
      case gov.VoteOption.VOTE_OPTION_NO_WITH_VETO:
        return Vote.demo(answerNoWithVeto: 1);
      case gov.VoteOption.VOTE_OPTION_YES:
        return Vote.demo(answerYes: 1);
      default:
        // Won't get here, but I have to have this for safety reasons.
        return Vote.demo();
    }
  }
}
