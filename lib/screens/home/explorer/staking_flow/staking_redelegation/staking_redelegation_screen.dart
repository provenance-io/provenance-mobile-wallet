import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_redelegation/redelegation_list.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_redelegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_redelegation/staking_redelegation_list.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingRedelegationScreen extends StatefulWidget {
  final DetailedValidator validator;

  final StakingFlowNavigator navigator;
  final TransactableAccount account;
  final Delegation delegation;

  const StakingRedelegationScreen({
    Key? key,
    required this.delegation,
    required this.validator,
    required this.account,
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
      widget.account,
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
    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SafeArea(
        child: StreamBuilder<StakingRedelegationDetails>(
          initialData: _bloc.stakingRedelegationDetails.value,
          stream: _bloc.stakingRedelegationDetails,
          builder: (context, snapshot) {
            final details = snapshot.data;

            if (details == null) {
              return Container();
            }
            final flowBloc = get<StakingFlowBloc>();
            return Scaffold(
              appBar: AppBar(
                primary: false,
                backgroundColor: Theme.of(context).colorScheme.neutral750,
                elevation: 0.0,
                centerTitle: true,
                title: PwText(
                  Strings.stakingRedelegateSelectForRedelegation,
                  style: PwTextStyle.subhead,
                ),
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
              body: Container(
                color: Theme.of(context).colorScheme.neutral750,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailsItem(
                      title: Strings.stakingRedelegateRedelegatingFrom,
                      endChild: PwText(
                        details.validator.moniker,
                        color: PwColor.neutralNeutral,
                        style: PwTextStyle.body,
                      ),
                    ),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                    StreamBuilder<StakingDetails>(
                      initialData: flowBloc.stakingDetails.value,
                      stream: flowBloc.stakingDetails,
                      builder: (context, snapshot) {
                        final stakingDetails = snapshot.data;
                        if (stakingDetails == null) {
                          return Container();
                        }
                        return Container(
                          padding: EdgeInsets.all(
                            Spacing.largeX3,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .neutral250,
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
                      },
                    ),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                    RedelegationList(validator: details.validator),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                    StakingRedelegationList(
                      details: details,
                      navigator: widget.navigator,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
