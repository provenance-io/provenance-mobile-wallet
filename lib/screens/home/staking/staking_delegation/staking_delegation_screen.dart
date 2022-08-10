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
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/denom_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingDelegationScreen extends StatefulWidget {
  final Delegation? delegation;
  final Reward? reward;

  final DetailedValidator validator;

  final String commissionRate;
  final TransactableAccount account;

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
      delegation: widget.delegation,
      reward: widget.reward,
      validator: widget.validator,
      commissionRate: widget.commissionRate,
      selectedDelegationType: SelectedDelegationType.delegate,
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
    final strings = Strings.of(context);
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
              strings.stakingDetailsButtonDelegate,
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
                  title: strings.stakingDelegateWarningAccountLockTitle,
                  message: strings.stakingDelegateWarningAccountLockMessage,
                  background: Theme.of(context).colorScheme.error,
                ),
              ValidatorDetails(validator: details.validator),
              PwListDivider.alternate(),
              DetailsHeader(
                title: strings.stakingDelegateDetails,
              ),
              PwListDivider.alternate(),
              DetailsItem.withHash(
                title: strings.stakingDelegateCurrentDelegation,
                hashString: details.delegation?.displayDenom ??
                    strings.stakingManagementNoHash,
                context: context,
              ),
              PwListDivider.alternate(),
              DetailsItem.withHash(
                title: strings.stakingDelegateAvailableBalance,
                hashString: stringNHashToHash(details.asset?.amount ?? "",
                        fractionDigits: 7)
                    .toString(),
                context: context,
              ),
              PwListDivider.alternate(),
              VerticalSpacer.largeX3(),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child:
                    PwText(Strings.of(context).stakingDelegateAmountToDelegate),
              ),
              Form(
                key: _formKey,
                child: StakingTextFormField(
                  hint:
                      Strings.of(context).stakingDelegateEnterAmountToDelegate,
                  textEditingController: _textEditingController,
                  scrollController: _scrollController,
                ),
              ),
              VerticalSpacer.largeX3(),
              PwListDivider.alternate(),
              PwButton(
                enabled: _formKey.currentState?.validate() == true &&
                    details.hashDelegated > Decimal.zero,
                onPressed: () {
                  if (_formKey.currentState?.validate() == false ||
                      details.hashDelegated <= Decimal.zero) {
                    return;
                  }
                  if (ValidatorStatus.jailed == widget.validator.status) {
                    final strings = Strings.of(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        final theme = Theme.of(context);
                        return AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.neutral750,
                          title: Text(
                            strings.stakingDelegateBeforeYouContinue,
                            style: theme.textTheme.footnote,
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                            strings.stakingDelegateValidatorJailedWarning,
                            style: theme.textTheme.body,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: PwText(
                                strings.stakingDelegateNoResponse.toUpperCase(),
                                style: PwTextStyle.bodyBold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                get<StakingFlowBloc>().showDelegationReview();
                              },
                              child: PwText(
                                strings.stakingDelegateYesResponse
                                    .toUpperCase(),
                                style: PwTextStyle.bodyBold,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    get<StakingFlowBloc>().showDelegationReview();
                  }
                },
                child: PwText(
                  Strings.of(context).continueName,
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
