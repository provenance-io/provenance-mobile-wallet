import 'package:decimal/decimal.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/warning_section.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/validator_card.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
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

  final TransactableAccount account;

  @override
  State<StatefulWidget> createState() => _StakingUndelegationScreenState();
}

class _StakingUndelegationScreenState extends State<StakingUndelegationScreen> {
  late final StakingDelegationBloc _bloc;
  late final TextEditingController _textEditingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _textEditingController.addListener(_onTextChanged);
    _bloc = StakingDelegationBloc(
      delegation: widget.delegation,
      validator: widget.validator,
      selectedDelegationType: SelectedDelegationType.undelegate,
      account: widget.account,
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
    _scrollController.dispose();
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
    final strings = Strings.of(context);

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
            title: PwText(
              strings.stakingUndelegateUndelegate,
              style: PwTextStyle.footnote,
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
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: Spacing.large),
            controller: _scrollController,
            children: [
              VerticalSpacer.largeX3(),
              WarningSection(
                title: strings.stakingUndelegateWarningUnbondingPeriodTitle,
                message: strings.stakingUndelegateWarningUnbondingPeriodMessage,
              ),
              VerticalSpacer.large(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  get<StakingFlowBloc>()
                      .redirectToRedelegation(widget.validator);
                },
                child: PwText(
                  strings.stakingUndelegateWarningSwitchValidators,
                  style: PwTextStyle.footnote,
                  underline: true,
                ),
              ),
              DetailsHeader(title: strings.stakingUndelegateUndelegating),
              PwListDivider.alternate(),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Spacing.small,
                ),
                child: PwText(
                  strings.stakingRedelegateFrom,
                  color: PwColor.neutral200,
                ),
              ),
              ValidatorCard(
                moniker: details.validator.moniker,
                imgUrl: details.validator.imgUrl,
                description: details.validator.description,
              ),
              DetailsHeader(
                title: strings.stakingUndelegateUndelegationDetails,
              ),
              PwListDivider.alternate(),
              DetailsItem.withHash(
                title: strings.stakingUndelegateAvailableForUndelegation,
                hashString: details.delegation?.displayDenom ??
                    strings.stakingManagementNoHash,
                context: context,
              ),
              PwListDivider.alternate(),
              VerticalSpacer.largeX3(),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: PwText(strings.stakingUndelegateAmountToUndelegate),
              ),
              Form(
                key: _formKey,
                child: StakingTextFormField(
                  hint: strings.stakingUndelegateEnterAmount,
                  textEditingController: _textEditingController,
                  scrollController: _scrollController,
                ),
              ),
              VerticalSpacer.largeX3(),
              PwListDivider.alternate(),
              PwButton(
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
                  strings.continueName,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  color: PwColor.neutralNeutral,
                  style: PwTextStyle.body,
                ),
              ),
              VerticalSpacer.largeX3(),
            ],
          ),
        );
      },
    );
  }
}
