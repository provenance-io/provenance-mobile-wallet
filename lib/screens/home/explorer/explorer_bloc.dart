import 'dart:async';

import 'package:get_it/get_it.dart';
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
    this.selectedType = Strings.dropDownDelegate,
    this.selectedStatus = Strings.dropDownAllStatuses,
    required this.address,
  });

// FIXME: delegates are a different type eventually
  final List<ProvenanceValidator> delegates;
  final List<ProvenanceValidator> validators;
  final String selectedType;
  final String selectedStatus;
  final String address;
}

enum ValidatorType {
  delegations,
  redelegations,
  unbonding,
}

enum ValidatorStatus {
  active,
  candidate,
  jailed,
}

extension ValidatorStatusStuff on ValidatorStatus {
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

extension ValidatorTypeStuff on ValidatorType {
  String get dropDownTitle {
    switch (this) {
      case ValidatorType.delegations:
        return Strings.dropDownDelegate;
      case ValidatorType.redelegations:
        return Strings.dropDownRedelegate;
      case ValidatorType.unbonding:
        return Strings.dropDownUndelegate;
    }
  }
}
