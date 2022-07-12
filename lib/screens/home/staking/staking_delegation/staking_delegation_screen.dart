import 'package:decimal/decimal.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/warning_section.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/validator_details.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingDelegationScreen extends StatefulWidget {
  final Delegation? delegation;
  final Reward? reward;

  final DetailedValidator validator;

  final String commissionRate;
  final Account account;

  const StakingDelegationScreen({
    Key? key,
    this.delegation,
    this.reward,
    required this.validator,
    required this.commissionRate,
    required this.account,
  }) : super(key: key);

  @override
  State<StakingDelegationScreen> createState() =>
      _StakingDelegationScreenState();
}

class _StakingDelegationScreenState extends State<StakingDelegationScreen> {
  late final StakingDelegationBloc _bloc;
  late final TextEditingController _textEditingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _textEditingController.addListener(_onTextChanged);
    _bloc = StakingDelegationBloc(
      widget.delegation,
      widget.validator,
      widget.commissionRate,
      SelectedDelegationType.delegate,
      widget.account,
      widget.reward,
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
    return StreamBuilder<StakingDelegationDetails>(
      initialData: _bloc.stakingDelegationDetails.value,
      stream: _bloc.stakingDelegationDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;

        if (null == details) {
          return Container();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.neutral750,
            elevation: 0.0,
            centerTitle: true,
            title: PwText(
              Strings.stakingDetailsButtonDelegate,
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
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: Spacing.large),
            children: [
              VerticalSpacer.largeX3(),
              if (details.hashInsufficient)
                WarningSection(
                  title: Strings.stakingDelegateWarningAccountLockTitle,
                  message: Strings.stakingDelegateWarningAccountLockMessage,
                  background: Theme.of(context).colorScheme.error,
                ),
              ValidatorDetails(validator: details.validator),
              PwListDivider.alternate(),
              DetailsHeader(
                title: Strings.stakingDelegateDetails,
              ),
              PwListDivider.alternate(),
              DetailsItem.withHash(
                title: Strings.stakingDelegateCurrentDelegation,
                hashString: details.delegation?.displayDenom ??
                    Strings.stakingManagementNoHash,
                context: context,
              ),
              PwListDivider.alternate(),
              DetailsItem.withHash(
                title: Strings.stakingDelegateAvailableBalance,
                hashString:
                    '${details.asset?.amount.nhashToHash(fractionDigits: 7) ?? "0"} ${Strings.stakingDelegateConfirmHash}',
                context: context,
              ),
              PwListDivider.alternate(),
              VerticalSpacer.largeX3(),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: PwText(Strings.stakingDelegateAmountToDelegate),
              ),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: StakingTextFormField(
                    hint: Strings.stakingDelegateEnterAmountToDelegate,
                    textEditingController: _textEditingController,
                    scrollController: _scrollController,
                  ),
                ),
              ),
              VerticalSpacer.largeX3(),
              PwListDivider.alternate(),
              Flexible(
                child: PwButton(
                  enabled: _formKey.currentState?.validate() == true &&
                      details.hashDelegated > Decimal.zero,
                  onPressed: () {
                    if (_formKey.currentState?.validate() == false ||
                        details.hashDelegated <= Decimal.zero) {
                      return;
                    }
                    get<StakingFlowBloc>().showDelegationReview();
                  },
                  child: PwText(
                    Strings.continueName,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
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
