import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_modal/staking_modal_bloc.dart';
import 'package:provenance_wallet/util/get.dart';

class StakingButtons extends StatelessWidget {
  const StakingButtons({
    Key? key,
    required SelectedModalType initialValue,
    required Function onActivation,
  })  : _activationValue = initialValue,
        _onActivation = onActivation,
        super(key: key);
  final SelectedModalType _activationValue;
  final Function _onActivation;

  @override
  Widget build(BuildContext context) {
    final bloc = get<StakingModalBloc>();
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
                bloc.updateSelectedModal(SelectedModalType.initial);
              },
              child: PwText(
                SelectedModalType.delegate.dropDownTitle,
                overflow: TextOverflow.ellipsis,
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
                overflow: TextOverflow.ellipsis,
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
