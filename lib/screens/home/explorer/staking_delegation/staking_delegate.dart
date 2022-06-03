import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/warning_section.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingDelegate extends StatefulWidget {
  const StakingDelegate({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StakingDelegateState();
}

class _StakingDelegateState extends State<StakingDelegate> {
  late final TextEditingController _textEditingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
    _textEditingController.addListener(listen);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(listen);
    _textEditingController.dispose();

    super.dispose();
  }

  void listen() {
    String text = _textEditingController.text;
    if (text.isEmpty) {
      return;
    }

    final number = num.tryParse(text) ?? 0;
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
        return ListView(
          children: [
            if (details.hashInsufficient)
              WarningSection(
                title: "Warning: Account will lock",
                message:
                    "In order to undelegate funds back into this account, the account will need to be able to pay the required fees. Delegating the specified amount of funds from this account will result in it being locked until another account sends it funds.",
                background: Theme.of(context).colorScheme.error,
              ),
            WarningSection(
              title: "Staking will lock your funds for 21+ days",
              message:
                  "You will need to undelegate in order for your staked assets to be liquid again. This process will take 21 days to complete.",
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
              title: "Available Balance",
              endChild: Flexible(
                child: PwText(
                  '${details.asset?.amount.nhashToHash(fractionDigits: 7) ?? "0"} hash',
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
              title: "Amount to Delegate",
              endChild: Flexible(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                      child: Form(
                    key: _formKey,
                    child: StakingTextFormField(
                      hint: 'hash',
                      submit: _submit,
                      textEditingController: _textEditingController,
                    ),
                  )),
                ],
              )),
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
                  if (details.delegation != null)
                    Flexible(
                      child: PwButton(
                        onPressed: () {
                          bloc.updateSelectedModal(
                              SelectedDelegationType.initial);
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
                  if (details.delegation != null) HorizontalSpacer.large(),
                  Flexible(
                    child: PwButton(
                      enabled: _formKey.currentState?.validate() == true &&
                          details.hashDelegated > 0,
                      onPressed: () {
                        if (_formKey.currentState?.validate() == false ||
                            0 == details.hashDelegated ||
                            details.hashDelegated.isNegative) {
                          return;
                        }
                        print("press registered");
                        //bloc.updateSelectedModal(SelectedModalType.initial);
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
