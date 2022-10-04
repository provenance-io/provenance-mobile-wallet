import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';

Color validatorColorForStatus(BuildContext context, ValidatorStatus status) {
  final scheme = Theme.of(context).colorScheme;
  switch (status) {
    case ValidatorStatus.active:
      return scheme.positive300;
    case ValidatorStatus.candidate:
      return scheme.secondaryContainer;
    case ValidatorStatus.jailed:
      return scheme.error;
  }
}
