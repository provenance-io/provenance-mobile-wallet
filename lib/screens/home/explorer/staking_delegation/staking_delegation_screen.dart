import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/warning_section.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingDelegationScreen extends StatefulWidget {
  final Delegation? delegation;

  final DetailedValidator validator;

  final String commissionRate;
  final AccountDetails accountDetails;
  final StakingFlowNavigator navigator;

  const StakingDelegationScreen({
    Key? key,
    this.delegation,
    required this.validator,
    required this.commissionRate,
    required this.accountDetails,
    required this.navigator,
  }) : super(key: key);

  @override
  State<StakingDelegationScreen> createState() =>
      _StakingDelegationScreenState();
}

class _StakingDelegationScreenState extends State<StakingDelegationScreen> {
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
      widget.commissionRate,
      SelectedDelegationType.delegate,
      widget.accountDetails,
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

    final number = num.tryParse(text) ?? 0;
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
                          textEditingController: _textEditingController,
                        ),
                      )),
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
                  child: PwButton(
                    enabled: _formKey.currentState?.validate() == true &&
                        details.hashDelegated > 0,
                    onPressed: () {
                      if (_formKey.currentState?.validate() == false ||
                          0 == details.hashDelegated ||
                          details.hashDelegated.isNegative) {
                        return;
                      }
                      widget.navigator.showDelegationReview();
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
              ),
            ],
          ),
        );
      },
    );
  }
}
