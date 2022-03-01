import 'dart:async';

import 'package:provenance_wallet/services/stat_service/stat_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';

class FundamentalsBloc extends Disposable {
  final _marketCap = BehaviorSubject.seeded("\$12.5B");
  final _validatorsCount = BehaviorSubject.seeded(10);
  final _transactions = BehaviorSubject.seeded("395.8k");
  final _blockTime = BehaviorSubject.seeded("6.36sec");

  final _service = get<StatService>();

  ValueStream<String> get marketCap => _marketCap.stream;
  ValueStream<int> get validatorsCount => _validatorsCount.stream;
  ValueStream<String> get transactions => _transactions.stream;
  ValueStream<String> get blockTime => _blockTime.stream;

  void load() async {
    final stats = await _service.getStats();
    if (stats == null) {
      return;
    }

    _marketCap.value = stats.marketCap;
    _validatorsCount.value = stats.validators;
    _transactions.value = stats.transactions;
    _blockTime.value = stats.blockTime;
  }

  @override
  FutureOr onDispose() {
    _marketCap.close();
    _validatorsCount.close();
    _transactions.close();
    _blockTime.close();
  }
}
