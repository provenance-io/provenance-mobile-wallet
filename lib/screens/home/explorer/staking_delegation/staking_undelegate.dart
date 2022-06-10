import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/warning_section.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingUndelegate extends StatefulWidget {
  const StakingUndelegate({
    Key? key,
    required this.navigator,
  }) : super(key: key);

  final StakingFlowNavigator navigator;

  @override
  State<StatefulWidget> createState() => _StakingUndelegateState();
}

class _StakingUndelegateState extends State<StakingUndelegate> {
  late final TextEditingController _textEditingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    String text = _textEditingController.text;
    if (text.isEmpty) {
      return;
    }

    final number = num.tryParse(text) ?? 0;
    get<StakingDelegationBloc>().updateHashDelegated(number);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = get<StakingDelegationBloc>();

    return StreamBuilder<StakingDelegationDetails>(
      initialData: bloc.stakingDelegationDetails.value,
      stream: bloc.stakingDelegationDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (details == null) {
          return Container();
        }
        return ListView(
          children: [
            WarningSection(
              title: Strings.stakingUndelegateWarningUnbondingPeriodTitle,
              message: Strings.stakingUndelegateWarningUnbondingPeriodMessage,
            ),
            WarningSection(
              title: Strings.stakingUndelegateWarningSwitchValidatorsTitle,
              message: Strings.stakingUndelegateWarningSwitchValidatorsMessage,
              background: Theme.of(context).colorScheme.primary500,
            ),
            DetailsItem(
              title: Strings.stakingUndelegateAvailableForUndelegation,
              endChild: PwText(
                details.delegation?.displayDenom ??
                    Strings.stakingManagementNoHash,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.largeX3,
                vertical: Spacing.xLarge,
              ),
              child: Flexible(
                child: Form(
                  key: _formKey,
                  child: StakingTextFormField(
                    hint: Strings.stakingDelegateConfirmHash,
                    textEditingController: _textEditingController,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.largeX3,
                vertical: Spacing.xLarge,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (details.delegation != null)
                    Flexible(
                      child: PwButton(
                        onPressed: () {
                          bloc.updateSelectedDelegationType(
                            SelectedDelegationType.initial,
                          );
                        },
                        child: PwText(
                          SelectedDelegationType.initial.dropDownTitle,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          color: PwColor.neutralNeutral,
                          style: PwTextStyle.body,
                        ),
                      ),
                    ),
                  if (details.delegation != null) HorizontalSpacer.large(),
                  Flexible(
                    child: PwButton(
                      enabled: _formKey.currentState?.validate() == true &&
                          details.hashDelegated > 0 &&
                          (details.delegation?.hashAmount ?? 0) >=
                              details.hashDelegated,
                      onPressed: () {
                        if (_formKey.currentState?.validate() == false ||
                            0 == details.hashDelegated ||
                            details.hashDelegated.isNegative) {
                          return;
                        }
                        widget.navigator.showReviewTransaction(
                          details.selectedDelegationType,
                        );
                      },
                      child: PwText(
                        SelectedDelegationType.undelegate.dropDownTitle,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        color: PwColor.neutralNeutral,
                        style: PwTextStyle.body,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
