import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

// FIXME: Not used/registered yet.
class StakingRedelegationBloc extends Disposable {
  StakingRedelegationBloc(
    final Delegation? delegation,
    final DetailedValidator validator,
    final String commissionRate,
    this._accountDetails,
  ) : _stakingDelegationDetails = BehaviorSubject.seeded(
          StakingDelegationDetails(
            validator,
            commissionRate,
            delegation,
            delegation != null
                ? SelectedDelegationType.initial
                : SelectedDelegationType.delegate,
            null,
            0,
            _accountDetails,
          ),
        );

  final BehaviorSubject<StakingDelegationDetails> _stakingDelegationDetails;
  final _isLoading = BehaviorSubject.seeded(false);
  final AccountDetails _accountDetails;
  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<StakingDelegationDetails> get stakingDelegationDetails =>
      _stakingDelegationDetails;

  @override
  FutureOr onDispose() {
    _isLoading.close();
    _stakingDelegationDetails.close();
  }

  Future<void> load() async {
    _isLoading.tryAdd(true);
    try {
      final asset = (await get<AssetService>()
              .getAssets(_accountDetails.coin, _accountDetails.address))
          .firstWhere((element) => element.denom == 'nhash');
      final oldDetails = _stakingDelegationDetails.value;
      _stakingDelegationDetails.tryAdd(
        StakingDelegationDetails(
          oldDetails.validator,
          oldDetails.commissionRate,
          oldDetails.delegation,
          oldDetails.selectedDelegationType,
          asset,
          oldDetails.hashDelegated,
          oldDetails.accountDetails,
        ),
      );
    } finally {
      _isLoading.tryAdd(false);
    }
  }

  void updateSelectedModal(SelectedDelegationType selected) {
    final oldDetails = _stakingDelegationDetails.value;
    _stakingDelegationDetails.tryAdd(
      StakingDelegationDetails(
        oldDetails.validator,
        oldDetails.commissionRate,
        oldDetails.delegation,
        selected,
        oldDetails.asset,
        oldDetails.hashDelegated,
        oldDetails.accountDetails,
      ),
    );
  }

  void updateHashRedelegated(num hashRedelegated) {
    final oldDetails = _stakingDelegationDetails.value;
    _stakingDelegationDetails.tryAdd(
      StakingDelegationDetails(
        oldDetails.validator,
        oldDetails.commissionRate,
        oldDetails.delegation,
        oldDetails.selectedDelegationType,
        oldDetails.asset,
        hashRedelegated,
        oldDetails.accountDetails,
      ),
    );
  }
}

class StakingRedelegationDetails {
  StakingRedelegationDetails(
    this.validator,
    this.commissionRate,
    this.delegation,
    this.asset,
    this.hashDelegated,
    this.accountDetails,
  );

  final Delegation? delegation;
  final DetailedValidator validator;
  final String commissionRate;
  final SelectedDelegationType selectedModalType =
      SelectedDelegationType.redelegate;
  final Asset? asset;
  final num hashDelegated;
  final AccountDetails accountDetails;
}
