import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

class WeightedVoteBloc extends Disposable {
  final Proposal _proposal;
  final TransactableAccount _account;
  final _weightedVoteDetails = BehaviorSubject.seeded(WeightedVoteDetails());

  WeightedVoteBloc(
    this._proposal,
    this._account,
  );

  ValueStream<WeightedVoteDetails> get weightedVoteDetails =>
      _weightedVoteDetails;

  @override
  FutureOr onDispose() {
    _weightedVoteDetails.close();
  }

  void updateWeight({
    double? yesAmount,
    double? noAmount,
    double? noWithVetoAmount,
    double? abstainAmount,
  }) {
    final oldDetails = _weightedVoteDetails.value;
    _weightedVoteDetails.tryAdd(
      WeightedVoteDetails(
        yesAmount: yesAmount ?? oldDetails.yesAmount,
        noAmount: noAmount ?? oldDetails.noAmount,
        abstainAmount: abstainAmount ?? oldDetails.abstainAmount,
        noWithVetoAmount: noWithVetoAmount ?? oldDetails.noWithVetoAmount,
      ),
    );
  }

  Future<void> doWeightedVote(
    double? gasAdjustment,
  ) async {
    var options = <gov.WeightedVoteOption>[];
    final details = _weightedVoteDetails.value;

    if (details.yesAmount > 0) {
      options.add(
        gov.WeightedVoteOption(
          option: gov.VoteOption.VOTE_OPTION_YES,
          weight: "${details.yesAmount}%",
        ),
      );
    }

    if (details.noAmount > 0) {
      options.add(
        gov.WeightedVoteOption(
          option: gov.VoteOption.VOTE_OPTION_NO,
          weight: "${details.noAmount}%",
        ),
      );
    }

    if (details.noWithVetoAmount > 0) {
      options.add(
        gov.WeightedVoteOption(
          option: gov.VoteOption.VOTE_OPTION_NO_WITH_VETO,
          weight: "${details.noWithVetoAmount}%",
        ),
      );
    }

    if (details.abstainAmount > 0) {
      options.add(
        gov.WeightedVoteOption(
          option: gov.VoteOption.VOTE_OPTION_ABSTAIN,
          weight: "${details.abstainAmount}%",
        ),
      );
    }

    final body = proto.TxBody(
      messages: [
        gov.MsgVoteWeighted(
          options: options,
          proposalId: _proposal.proposalId as Int64,
          voter: _account.address,
        ).toAny(),
      ],
    );

    final privateKey = await get<AccountService>().loadKey(_account.id);

    final adjustedEstimate =
        await (get<TransactionHandler>()).estimateGas(body, _account.publicKey);

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
}

class WeightedVoteDetails {
  WeightedVoteDetails({
    this.yesAmount = 0,
    this.noAmount = 0,
    this.noWithVetoAmount = 0,
    this.abstainAmount = 0,
  });

  final double yesAmount;
  final double noAmount;
  final double noWithVetoAmount;
  final double abstainAmount;
}
