import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/stat_service/stat_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:rxdart/rxdart.dart';

class LandingBloc extends Disposable {
  final _marketCap = BehaviorSubject.seeded("\$12.5B");
  final _validatorsCount = BehaviorSubject.seeded(10);
  final _transactions = BehaviorSubject.seeded("395.8k");
  final _blockTime = BehaviorSubject.seeded("6.36sec");

  final _service = get<StatService>();

  ValueStream<String> get marketCap => _marketCap.stream;
  ValueStream<int> get validatorsCount => _validatorsCount.stream;
  ValueStream<String> get transactions => _transactions.stream;
  ValueStream<String> get blockTime => _blockTime.stream;

  Future<void> load() async {
    final stats = await _service.getStats(Coin.mainNet);
    if (stats == null) {
      return;
    }

    _marketCap.value = stats.marketCap;
    _validatorsCount.value = stats.validators;
    _transactions.value = stats.transactions;
    _blockTime.value = stats.blockTime;
  }

  Future<void> doAuth(BuildContext context) async {
    await get<LocalAuthHelper>().auth(context);
  }

  @override
  FutureOr onDispose() {
    _marketCap.close();
    _validatorsCount.close();
    _transactions.close();
    _blockTime.close();
  }
}
