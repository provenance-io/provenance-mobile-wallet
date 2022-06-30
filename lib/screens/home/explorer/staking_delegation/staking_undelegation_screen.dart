import 'package:decimal/decimal.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/warning_section.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingUndelegationScreen extends StatefulWidget {
  const StakingUndelegationScreen({
    Key? key,
    this.delegation,
    required this.validator,
    required this.account,
  }) : super(key: key);

  final Delegation? delegation;

  final DetailedValidator validator;

  final Account account;

  @override
  State<StatefulWidget> createState() => _StakingUndelegationScreenState();
}

class _StakingUndelegationScreenState extends State<StakingUndelegationScreen> {
  late final StakingDelegationBloc _bloc;
  late final TextEditingController _textEditingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _textEditingController.addListener(_onTextChanged);
    _bloc = StakingDelegationBloc(
      widget.delegation,
      widget.validator,
      "",
      SelectedDelegationType.undelegate,
      widget.account,
    );
    get.registerSingleton<StakingDelegationBloc>(_bloc);
    _bloc.load();
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<StakingDelegationBloc>();
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    String text = _textEditingController.text;
    if (text.isEmpty) {
      return;
    }

    final number = Decimal.tryParse(text) ?? Decimal.zero;
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
              WarningSection(
                title: Strings.stakingUndelegateWarningUnbondingPeriodTitle,
                message: Strings.stakingUndelegateWarningUnbondingPeriodMessage,
              ),
              WarningSection(
                title: Strings.stakingUndelegateWarningSwitchValidatorsTitle,
                message:
                    Strings.stakingUndelegateWarningSwitchValidatorsMessage,
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
                    Flexible(
                      child: PwButton(
                        enabled: _formKey.currentState?.validate() == true &&
                            details.hashDelegated > Decimal.zero &&
                            (details.delegation?.hashAmount ?? Decimal.zero) >=
                                details.hashDelegated,
                        onPressed: () {
                          if (_formKey.currentState?.validate() == false ||
                              details.hashDelegated <= Decimal.zero) {
                            return;
                          }
                          get<StakingFlowBloc>().showUndelegationReview();
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
          ),
        );
      },
    );
  }
}
