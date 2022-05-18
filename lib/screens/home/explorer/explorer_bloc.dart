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
  List<ProvenanceValidator> delegates;
  List<ProvenanceValidator> validators;
  String selectedType;
  String selectedStatus;
  String address;
}

enum ValidatorType {
  delegate,
  redelegate,
  undelegate,
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
      case ValidatorType.delegate:
        return Strings.dropDownDelegate;
      case ValidatorType.redelegate:
        return Strings.dropDownRedelegate;
      case ValidatorType.undelegate:
        return Strings.dropDownUndelegate;
    }
  }
}
