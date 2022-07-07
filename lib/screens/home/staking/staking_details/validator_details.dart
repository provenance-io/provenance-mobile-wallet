import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/warning_section.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/validator_card.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/strings.dart';

class ValidatorDetails extends StatelessWidget {
  final DetailedValidator validator;

  const ValidatorDetails({
    Key? key,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WarningSection(
          title: Strings.stakingDelegateWarningFundsLockTitle,
          message: Strings.stakingDelegateWarningFundsLockMessage,
        ),
        DetailsHeader(
          title: Strings.stakingDetailsDelegating,
        ),
        PwListDivider.alternate(),
        VerticalSpacer.large(),
        ValidatorCard(
          moniker: validator.moniker,
          imgUrl: validator.imgUrl,
          description: validator.description,
        ),
        PwListDivider.alternate(),
      ],
    );
  }
}
