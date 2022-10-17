import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:provenance_dart/proto_cosmos_gov_v1beta1.dart' as gov;
import 'package:provenance_wallet/common/classes/transaction_bloc.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/extensions/double_extensions.dart';
import 'package:rxdart/rxdart.dart';

class WeightedVoteBloc extends TransactionBloc {
  final Proposal _proposal;
  final _weightedVoteDetails = BehaviorSubject.seeded(WeightedVoteDetails());

  WeightedVoteBloc(
    this._proposal,
    TransactableAccount account,
  ) : super(account);

  ValueStream<WeightedVoteDetails> get weightedVoteDetails =>
      _weightedVoteDetails;

  @override
  gov.MsgVoteWeighted getMessage() {
    var options = <gov.WeightedVoteOption>[];
    final details = _weightedVoteDetails.value;

    if (details.yesAmount > 0) {
      options.add(
        gov.WeightedVoteOption(
          option: gov.VoteOption.VOTE_OPTION_YES,
          weight: details.yesAmount.toVoteWeight(),
        ),
      );
    }

    if (details.noAmount > 0) {
      options.add(
        gov.WeightedVoteOption(
          option: gov.VoteOption.VOTE_OPTION_NO,
          weight: details.noAmount.toVoteWeight(),
        ),
      );
    }

    if (details.noWithVetoAmount > 0) {
      options.add(
        gov.WeightedVoteOption(
          option: gov.VoteOption.VOTE_OPTION_NO_WITH_VETO,
          weight: details.noWithVetoAmount.toVoteWeight(),
        ),
      );
    }

    if (details.abstainAmount > 0) {
      options.add(
        gov.WeightedVoteOption(
          option: gov.VoteOption.VOTE_OPTION_ABSTAIN,
          weight: details.abstainAmount.toVoteWeight(),
        ),
      );
    }

    return gov.MsgVoteWeighted(
      options: options,
      proposalId: Int64.parseInt(_proposal.proposalId.toString()),
      voter: account.address,
    );
  }

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
