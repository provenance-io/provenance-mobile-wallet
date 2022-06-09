import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/redelegation_list.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingRedelegationScreen extends StatefulWidget {
  final DetailedValidator validator;

  final StakingFlowNavigator navigator;
  final AccountDetails accountDetails;
  final Delegation delegation;

  const StakingRedelegationScreen({
    Key? key,
    required this.delegation,
    required this.validator,
    required this.accountDetails,
    required this.navigator,
  }) : super(key: key);

  @override
  _StakingRedelegationScreenState createState() =>
      _StakingRedelegationScreenState();
}

class _StakingRedelegationScreenState extends State<StakingRedelegationScreen> {
  late final TextEditingController _textEditingController;
  late final StakingRedelegationBloc _bloc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _bloc = StakingRedelegationBloc(
      widget.validator,
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

        if (details == null) {
          return Container(
            child: Stack(
              children: const [
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
            color: Theme.of(context).colorScheme.neutral750,
          );
        }
        final flowBloc = get<StakingFlowBloc>();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.neutral750,
            elevation: 0.0,
            centerTitle: true,
            title: PwText(details.validator.moniker),
            leading: Padding(
              padding: EdgeInsets.only(left: 21),
              child: IconButton(
                icon: PwIcon(
                  PwIcons.back,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          body: ListView(
            children: [
              StreamBuilder<StakingDetails>(
                  initialData: flowBloc.stakingDetails.value,
                  stream: flowBloc.stakingDetails,
                  builder: (context, snapshot) {
                    final stakingDetails = snapshot.data;
                    if (stakingDetails == null) {
                      return Container(
                        child: Stack(
                          children: const [
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ),
                        color: Theme.of(context).colorScheme.neutral750,
                      );
                    }
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.xxLarge,
                      ),
                      child: Row(
                        children: [
                          PwText(
                            Strings.dropDownStateHeader,
                            color: PwColor.neutralNeutral,
                            style: PwTextStyle.body,
                          ),
                          HorizontalSpacer.large(),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.neutral250,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: Spacing.medium,
                              ),
                              child: PwDropDown<ValidatorSortingState>(
                                initialValue: stakingDetails.selectedSort,
                                items: ValidatorSortingState.values,
                                isExpanded: true,
                                onValueChanged: (item) {
                                  flowBloc.updateSort(item);
                                },
                                builder: (item) => PwText(
                                  item.dropDownTitle,
                                  color: PwColor.neutralNeutral,
                                  style: PwTextStyle.body,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.largeX3,
                  vertical: Spacing.xLarge,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Flexible(
                      //fit: FlexFit.tight,
                      child: RedelegationList(),
                    ),
                  ],
                ),
              ),
              PwListDivider(
                indent: Spacing.largeX3,
              ),
              DetailsItem(
                title: Strings.stakingRedelegateAvailableForRedelegation,
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
                child: Flexible(
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
                      widget.navigator.showRedelegationReview();
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
              ),
            ],
          ),
        );
      },
    );
  }
}
