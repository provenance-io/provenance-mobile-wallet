import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_data_screen.dart';
import 'package:provenance_wallet/common/widgets/pw_gas_adjustment_slider.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/common/widgets/pw_transaction_complete_screen.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/proposals/deposit_confirm/deposit_slider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/screens/home/view_more/hidden_proposal_creation/proposal_creation_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class HiddenProposalCreationScreen extends StatefulWidget {
  const HiddenProposalCreationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HiddenProposalCreationScreen> createState() =>
      _HiddenProposalCreationScreenState();
}

class _HiddenProposalCreationScreenState
    extends State<HiddenProposalCreationScreen> {
  double _gasEstimate = defaultGasEstimate;
  late final ProposalCreationBloc _bloc;

  late final TextEditingController _titleEditingController;
  late final TextEditingController _descriptionEditingController;

  @override
  void initState() {
    final account = get<AccountService>().events.selected.value!;
    _bloc = ProposalCreationBloc(
      account,
    );
    _titleEditingController = TextEditingController(text: "");
    _descriptionEditingController = TextEditingController(text: "");
    _titleEditingController.addListener(_onTitleChanged);
    _descriptionEditingController.addListener(_onDescriptionChanged);
    get.registerSingleton<ProposalCreationBloc>(_bloc);
    _bloc.load();
    super.initState();
  }

  @override
  void dispose() {
    _titleEditingController.removeListener(_onTitleChanged);
    _titleEditingController.dispose();
    _descriptionEditingController.removeListener(_onDescriptionChanged);
    _descriptionEditingController.dispose();
    get.unregister<ProposalCreationBloc>();
    super.dispose();
  }

  void _onTitleChanged() {
    String text = _titleEditingController.text;
    if (text.isEmpty) {
      return;
    }

    _bloc.updateTitle(text);
  }

  void _onDescriptionChanged() {
    String text = _descriptionEditingController.text;
    if (text.isEmpty) {
      return;
    }

    _bloc.updateDescription(text);
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.neutral750,
        elevation: 0.0,
        centerTitle: true,
        title: PwText(
          strings.devCreateProposal,
          style: PwTextStyle.footnote,
          textAlign: TextAlign.left,
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
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 21),
            child: PwTextButton(
              minimumSize: Size(
                80,
                50,
              ),
              onPressed: () {
                final data = _bloc.getMessageJson();
                Navigator.of(context).push(PwDataScreen(
                  title: strings.stakingConfirmData,
                  data: data,
                ).route());
              },
              child: PwText(
                strings.stakingConfirmData,
                style: PwTextStyle.footnote,
                underline: true,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: StreamBuilder<ProposalCreationDetails?>(
            initialData: _bloc.creationDetails.value,
            stream: _bloc.creationDetails,
            builder: (context, snapshot) {
              final details = snapshot.data;

              if (details == null || details.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: Spacing.large),
                      children: [
                        DetailsHeader(
                          title: strings.devCreateProposalDetails,
                        ),
                        PwListDivider.alternate(),
                        StakingTextFormField(
                          hint: strings.devProposalTitle,
                          textEditingController: _titleEditingController,
                          keyboardType: TextInputType.name,
                        ),
                        VerticalSpacer.large(),
                        PwListDivider.alternate(),
                        VerticalSpacer.large(),
                        StakingTextFormField(
                          hint: strings.devProposalDescription,
                          textEditingController: _descriptionEditingController,
                          keyboardType: TextInputType.name,
                        ),
                        VerticalSpacer.large(),
                        PwListDivider.alternate(),
                        DetailsItem.fromStrings(
                          title: strings.stakingDelegateAvailableBalance,
                          value:
                              strings.hashAmount(details.hashAmount.toString()),
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.withRowChildren(
                          title: strings.devInitialDepositAmount,
                          children: [
                            PwText(
                              strings.hashAmount(
                                  details.initialDeposit.toInt().toString()),
                              style: PwTextStyle.footnote,
                            )
                          ],
                        ),
                        DepositSlider(
                          max: details.hashAmount,
                          thumbColor: Theme.of(context).colorScheme.primary550,
                          onChanged: (changed) =>
                              _bloc.updateInitialDeposit(changed),
                        ),
                        PwListDivider.alternate(),
                        PwGasAdjustmentSlider(
                          title: strings.stakingConfirmGasAdjustment,
                          startingValue: defaultGasEstimate,
                          onValueChanged: (value) {
                            setState(() {
                              _gasEstimate = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  PwListDivider.alternate(),
                  VerticalSpacer.large(),
                  Padding(
                    padding: EdgeInsets.only(
                      left: Spacing.large,
                      right: Spacing.large,
                      bottom: Spacing.largeX3,
                    ),
                    child: PwButton(
                      enabled: details.title.isNotEmpty &&
                          details.description.isNotEmpty,
                      onPressed: () async {
                        await ModalLoadingRoute.showLoading(
                          context,
                          minDisplayTime: Duration(milliseconds: 500),
                        );
                        await _sendProposal(_gasEstimate, context);
                      },
                      child: PwText(
                        strings.devConfirmProposal,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        color: PwColor.neutralNeutral,
                        style: PwTextStyle.body,
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Future<void> _sendProposal(
    double? gasEstimate,
    BuildContext context,
  ) async {
    final navigator = Navigator.of(context);
    try {
      final response = await _bloc.sendTransaction(gasEstimate);
      ModalLoadingRoute.dismiss(context);
      navigator.pushReplacement(
        PwTransactionCompleteScreen(
          title: Strings.of(context).devProposalComplete,
          response: response,
          onComplete: () => navigator.pop(),
          onPressed: () {
            navigator.push(PwDataScreen(
              title: Strings.of(context).transactionResponse,
              data: response,
            ).route());
          },
        ).route(),
      );
    } catch (err) {
      await _showErrorModal(err, context);
    }
  }

  Future<void> _showErrorModal(Object error, BuildContext context) async {
    ModalLoadingRoute.dismiss(context);
    await showDialog(
      context: context,
      builder: (context) {
        return ErrorDialog(
          error: error.toString(),
        );
      },
    );
  }
}
