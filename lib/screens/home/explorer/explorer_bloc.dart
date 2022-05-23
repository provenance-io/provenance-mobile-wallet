import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/strings.dart';

class ExplorerBloc extends Disposable {
  @override
  FutureOr onDispose() {
    // TODO: implement onDispose
    throw UnimplementedError();
  }
}

class StakingDetails {
  StakingDetails({
    required this.delegates,
    required this.validators,
    this.selectedState = Strings.dropDownDelegate,
    this.selectedStatus = Strings.dropDownAllStatuses,
    required this.address,
  });

// FIXME: delegates are a different type eventually
  final List<Delegation> delegates;
  final List<ProvenanceValidator> validators;
  final String selectedState;
  final String selectedStatus;
  final String address;
}

enum DelegationState {
  bonded,
  redelegated,
  unbonded,
}

enum ValidatorStatus {
  active,
  candidate,
  jailed,
}

extension ValidatorStatusExtension on ValidatorStatus {
  String get dropDownTitle {
    switch (this) {
      case ValidatorStatus.active:
        return Strings.dropDownActive;
      case ValidatorStatus.candidate:
        return Strings.dropDownCandidate;
      case ValidatorStatus.jailed:
        return Strings.dropDownJailed;
    }
  }
}

extension DelegationStateExtension on DelegationState {
  String get dropDownTitle {
    switch (this) {
      case DelegationState.bonded:
        return Strings.dropDownDelegate;
      case DelegationState.redelegated:
        return Strings.dropDownRedelegate;
      case DelegationState.unbonded:
        return Strings.dropDownUndelegate;
    }
  }

  String get urlRoute {
    switch (this) {
      case DelegationState.bonded:
        return 'delegations';
      case DelegationState.redelegated:
        return 'redelegations';
      case DelegationState.unbonded:
        return 'unbonding';
    }
  }
}
