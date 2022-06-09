import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_redelegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingRedelegationList extends StatefulWidget {
  const StakingRedelegationList({
    Key? key,
    required this.details,
    required this.navigator,
  }) : super(key: key);

  final StakingRedelegationDetails details;
  final StakingFlowNavigator navigator;

  @override
  State<StatefulWidget> createState() => StakingRedelegationListState();
}

class StakingRedelegationListState extends State<StakingRedelegationList> {
  final StakingFlowBloc _bloc = get<StakingFlowBloc>();
  late final TextEditingController _textEditingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _bloc.load();
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
    get<StakingRedelegationBloc>().updateHashRedelegated(number);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          StreamBuilder<StakingDetails>(
            initialData: _bloc.stakingDetails.value,
            stream: _bloc.stakingDetails,
            builder: (context, snapshot) {
              final stakingDetails = snapshot.data;
              if (stakingDetails == null) {
                return Container();
              }
              return ListView(
                children: [
                  DetailsItem(
                    title: Strings.stakingRedelegateAvailableForRedelegation,
                    endChild: Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: PwText(
                              widget.details.delegation.displayDenom,
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
                            widget.details.hashRedelegated > 0 &&
                            widget.details.hashRedelegated <=
                                widget.details.delegation.hashAmount &&
                            widget.details.toRedelegate != null,
                        onPressed: () {
                          if (_formKey.currentState?.validate() == false ||
                              0 == widget.details.hashRedelegated ||
                              widget.details.hashRedelegated.isNegative) {
                            return;
                          }
                          widget.navigator.showRedelegationReview();
                        },
                        child: PwText(
                          widget.details.selectedDelegationType.dropDownTitle,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          color: PwColor.neutralNeutral,
                          style: PwTextStyle.body,
                        ),
                      ),
                    ),
                  ),
                  VerticalSpacer.xLarge(),
                ],
              );
            },
          ),
          StreamBuilder<bool>(
            initialData: _bloc.isLoadingValidators.value,
            stream: _bloc.isLoadingValidators,
            builder: (context, snapshot) {
              final isLoading = snapshot.data ?? false;
              if (isLoading) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  child: SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              return Container();
            },
          ),
        ],
      ),
    );
  }
}
