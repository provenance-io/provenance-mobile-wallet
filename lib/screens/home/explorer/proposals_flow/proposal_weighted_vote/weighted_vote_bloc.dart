import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:rxdart/rxdart.dart';

class WeightedVoteBloc extends Disposable {
  final _weightedVoteDetails = BehaviorSubject.seeded(WeightedVoteDetails());

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
          noWithVetoAmount: noWithVetoAmount ?? oldDetails.noWithVetoAmount),
    );
  }
}

class WeightedVoteDetails {
  WeightedVoteDetails({
    this.yesAmount = 100,
    this.noAmount = 0,
    this.noWithVetoAmount = 0,
    this.abstainAmount = 0,
  });

  final double yesAmount;
  final double noAmount;
  final double noWithVetoAmount;
  final double abstainAmount;
}
