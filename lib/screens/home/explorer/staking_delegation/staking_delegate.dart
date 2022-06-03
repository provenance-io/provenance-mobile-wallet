import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/warning_section.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingDelegate extends StatefulWidget {
  StakingDelegate({
    Key? key,
    required this.navigator,
  }) : super(key: key);

  StakingFlowNavigator navigator;

  @override
  State<StatefulWidget> createState() => _StakingDelegateState();
}

class _StakingDelegateState extends State<StakingDelegate> {
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
            if (details.hashInsufficient)
              WarningSection(
                title: Strings.stakingDelegateWarningAccountLockTitle,
                message: Strings.stakingDelegateWarningAccountLockMessage,
                background: Theme.of(context).colorScheme.error,
              ),
            WarningSection(
              title: Strings.stakingDelegateWarningFundsLockTitle,
              message: Strings.stakingDelegateWarningFundsLockMessage,
            ),
            DetailsItem(
              title: Strings.stakingManagementMyDelegation,
              endChild: Flexible(
                child: PwText(
                  details.delegation?.displayDenom ??
                      Strings.stakingManagementNoHash,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: PwTextStyle.body,
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.stakingDelegateAvailableBalance,
              endChild: Flexible(
                child: PwText(
                  '${details.asset?.amount.nhashToHash(fractionDigits: 7) ?? "0"} ${Strings.stakingDelegateConfirmHash}',
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: PwTextStyle.body,
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.stakingDelegateAmountToDelegate,
              endChild: Flexible(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                      child: Form(
                    key: _formKey,
                    child: StakingTextFormField(
                      hint: Strings.stakingDelegateConfirmHash,
                      submit: _submit,
                      textEditingController: _textEditingController,
                    ),
                  )),
                ],
              )),
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
                              SelectedDelegationType.initial);
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
                          details.hashDelegated > 0,
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
                        SelectedDelegationType.delegate.dropDownTitle,
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

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      print("submitted ${_textEditingController.text}");
    }
  }
}
