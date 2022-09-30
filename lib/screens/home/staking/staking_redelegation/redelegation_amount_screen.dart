import 'package:decimal/decimal.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/validator_card.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class RedelegationAmountScreen extends StatefulWidget {
  const RedelegationAmountScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<RedelegationAmountScreen> createState() =>
      _RedelegationAmountScreenState();
}

class _RedelegationAmountScreenState extends State<RedelegationAmountScreen> {
  late final TextEditingController _textEditingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    Provider.of<StakingRedelegationBloc>(context, listen: false)
        .updateHashRedelegated(number);
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    final bloc = Provider.of<StakingRedelegationBloc>(context, listen: false);
    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SafeArea(
        child: StreamBuilder<StakingRedelegationDetails>(
          initialData: bloc.stakingRedelegationDetails.value,
          stream: bloc.stakingRedelegationDetails,
          builder: (context, snapshot) {
            final details = snapshot.data;

            if (details == null) {
              return Container();
            }
            return Scaffold(
              appBar: AppBar(
                primary: false,
                backgroundColor: Theme.of(context).colorScheme.neutral750,
                elevation: 0.0,
                centerTitle: true,
                title: PwText(
                  strings.stakingRedelegateRedelegate,
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailsHeader(
                        title: strings.stakingRedelegateRedelegating,
                      ),
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Spacing.small,
                        ),
                        child: PwText(
                          strings.stakingRedelegateTo,
                          color: PwColor.neutral200,
                        ),
                      ),
                      ValidatorCard(
                        moniker: details.toRedelegate?.moniker,
                        imgUrl: details.toRedelegate?.imgUrl,
                      ),
                      DetailsHeader(title: strings.stakingDelegateDetails),
                      PwListDivider.alternate(),
                      DetailsItem.withHash(
                        title:
                            strings.stakingRedelegateAvailableForRedelegation,
                        hashString: details.delegation.displayDenom,
                        context: context,
                      ),
                      PwListDivider.alternate(),
                      VerticalSpacer.largeX3(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child:
                            PwText(strings.stakingDelegateAmountToRedelegate),
                      ),
                      Flexible(
                        child: Form(
                          key: _formKey,
                          child: StakingTextFormField(
                            hint: strings.stakingRedelegateEnterAmount,
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
                              details.hashRedelegated > Decimal.zero,
                          onPressed: () {
                            if (_formKey.currentState?.validate() == false ||
                                details.hashRedelegated <= Decimal.zero) {
                              return;
                            }
                            Provider.of<StakingDetailsBloc>(context,
                                    listen: false)
                                .showRedelegationReview();
                          },
                          child: PwText(
                            strings.continueName,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
