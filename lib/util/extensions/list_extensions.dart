import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';

extension ListValidatorSortingExtension on List<ProvenanceValidator> {
  List<ProvenanceValidator> sortDescendingBy({
    required ValidatorSortingState state,
  }) {
    sort((a, b) {
      int sort;
      switch (state) {
        case ValidatorSortingState.votingPower:
          sort = b.votingPower.compareTo(a.votingPower);
          break;
        case ValidatorSortingState.delegators:
          sort = b.delegators.compareTo(a.delegators);
          break;
        case ValidatorSortingState.commission:
          sort = b.rawCommission.compareTo(a.rawCommission);
          break;
        case ValidatorSortingState.alphabetically:
          sort = 0;
          break;
      }
      if (sort != 0) {
        return sort;
      }
      return a.moniker.toLowerCase().compareTo(b.moniker.toLowerCase());
    });
    return toList();
  }
}
