import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class StakingDelegationBloc extends Disposable {
  final BehaviorSubject<StakingDelegationDetails> _stakingDelegationDetails;
  final _isLoading = BehaviorSubject.seeded(false);
  StakingDelegationBloc(
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

  void updateSelectedDelegationType(SelectedDelegationType selected) {
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

  void updateHashDelegated(num hashDelegated) {
    final oldDetails = _stakingDelegationDetails.value;
    _stakingDelegationDetails.tryAdd(
      StakingDelegationDetails(
        oldDetails.validator,
        oldDetails.commissionRate,
        oldDetails.delegation,
        oldDetails.selectedDelegationType,
        oldDetails.asset,
        hashDelegated,
        oldDetails.accountDetails,
      ),
    );
  }
}

class StakingDelegationDetails {
  StakingDelegationDetails(
    this.validator,
    this.commissionRate,
    this.delegation,
    this.selectedDelegationType,
    this.asset,
    this.hashDelegated,
    this.accountDetails,
  );

  final Delegation? delegation;
  final DetailedValidator validator;
  final String commissionRate;
  final SelectedDelegationType selectedDelegationType;
  final Asset? asset;
  final num hashDelegated;
  final AccountDetails accountDetails;

  bool get hashInsufficient {
    if (0 == hashDelegated) {
      return false;
    }
    final remainingHash =
        num.tryParse(asset?.amount.nhashToHash(fractionDigits: 7) ?? "");

    if (null == remainingHash) {
      return true;
    }

    return hashDelegated > remainingHash;
  }
}

enum SelectedDelegationType {
  initial,
  delegate,
  claimRewards,
  undelegate,
  redelegate,
}

extension SelectedDelegationTypeExtension on SelectedDelegationType {
  String get dropDownTitle {
    switch (this) {
      case SelectedDelegationType.initial:
        return "Back";
      case SelectedDelegationType.delegate:
      case SelectedDelegationType.redelegate:
      case SelectedDelegationType.undelegate:
        return name.capitalize();
      case SelectedDelegationType.claimRewards:
        return "Claim Rewards";
    }
  }
}
