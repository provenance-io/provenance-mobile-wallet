import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/abbreviated_validator.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingRedelegate extends StatefulWidget {
  const StakingRedelegate({
    Key? key,
    required this.navigator,
    required this.accountDetails,
    required this.delegation,
  }) : super(key: key);

  final StakingFlowNavigator navigator;
  final AccountDetails accountDetails;
  final Delegation delegation;

  @override
  State<StatefulWidget> createState() => _StakingRedelegateState();
}

class _StakingRedelegateState extends State<StakingRedelegate> {
  late final TextEditingController _textEditingController;
  late final StakingRedelegationBloc _bloc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _bloc = StakingRedelegationBloc(
      widget.delegation,
      widget.accountDetails,
    );
    get.registerSingleton<StakingRedelegationBloc>(_bloc);
    _bloc.load();
    _textEditingController = TextEditingController();
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
    get.unregister<StakingRedelegationBloc>();

    super.dispose();
  }

  void _onTextChanged() {
    String text = _textEditingController.text;
    if (text.isEmpty) {
      return;
    }

    final number = num.tryParse(text) ?? 0;
    _bloc.updateHashRedelegated(number);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StakingRedelegationDetails>(
      initialData: _bloc.stakingRedelegationDetails.value,
      stream: _bloc.stakingRedelegationDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (details == null || details.validators.isEmpty) {
          return Container();
        }
        return ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.largeX3,
                vertical: Spacing.xLarge,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    //fit: FlexFit.tight,
                    child: PwDropDown<AbbreviatedValidator>(
                      initialValue: details.validators.first,
                      items: details.validators,
                      isExpanded: true,
                      onValueChanged: (item) => _bloc.selectRedelegation(item),
                      builder: (item) => Row(
                        children: [
                          Flexible(
                            child: PwText(
                              item.moniker,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              color: PwColor.neutralNeutral,
                              style: PwTextStyle.body,
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Expanded(child: Container()),
                ],
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.stakingDelegateAvailableForRedelegation,
              endChild: Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: PwText(
                        details.delegation.displayDenom,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: PwTextStyle.body,
                      ),
                    ),
                  ],
                ),
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
                    submit: _submit,
                    textEditingController: _textEditingController,
                  ),
                ),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: PwButton(
                      onPressed: () {
                        get<StakingDelegationBloc>()
                            .updateSelectedDelegationType(
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
                  HorizontalSpacer.large(),
                  Flexible(
                    child: PwButton(
                      enabled: _formKey.currentState?.validate() == true &&
                          details.hashRedelegated > 0 &&
                          details.hashRedelegated <=
                              details.delegation.hashAmount,
                      onPressed: () {
                        if (_formKey.currentState?.validate() == false ||
                            0 == details.hashRedelegated ||
                            details.hashRedelegated.isNegative) {
                          return;
                        }
                        widget.navigator.showReviewTransaction(
                          details.selectedDelegationType,
                        );
                      },
                      child: PwText(
                        details.selectedDelegationType.dropDownTitle,
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
