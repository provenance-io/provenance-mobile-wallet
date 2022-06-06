import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/util/get.dart';

class StakingButtons extends StatelessWidget {
  const StakingButtons({
    Key? key,
    required SelectedDelegationType initialValue,
    required Function onActivation,
  })  : _activationValue = initialValue,
        _onActivation = onActivation,
        super(key: key);
  final SelectedDelegationType _activationValue;
  final Function _onActivation;

  @override
  Widget build(BuildContext context) {
    final bloc = get<StakingDelegationBloc>();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.largeX3,
        vertical: Spacing.xLarge,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: PwButton(
              onPressed: () {
                bloc.updateSelectedDelegationType(
                    SelectedDelegationType.initial);
              },
              child: PwText(
                SelectedDelegationType.delegate.dropDownTitle,
                overflow: TextOverflow.fade,
                softWrap: false,
                color: PwColor.neutralNeutral,
                style: PwTextStyle.body,
              ),
            ),
          ),
          HorizontalSpacer.large(),
          Flexible(
            child: PwButton(
              onPressed: () => _onActivation(),
              child: PwText(
                _activationValue.dropDownTitle,
                overflow: TextOverflow.fade,
                softWrap: false,
                color: PwColor.neutralNeutral,
                style: PwTextStyle.body,
              ),
            ),
          )
        ],
      ),
    );
  }
}
