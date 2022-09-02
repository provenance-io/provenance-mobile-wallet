import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_gas_adjustment_slider.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/proposals/deposit_confirm/deposit_confirm_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/deposit_confirm/deposit_slider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/denom_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class DepositConfirmScreen extends StatefulWidget {
  const DepositConfirmScreen({
    Key? key,
    required this.account,
    required this.proposal,
  }) : super(key: key);

  final TransactableAccount account;
  final Proposal proposal;

  @override
  State<StatefulWidget> createState() => _DepositConfirmScreenState();
}

class _DepositConfirmScreenState extends State<DepositConfirmScreen> {
  double _gasEstimate = defaultGasEstimate;
  late final DepositConfirmBloc _bloc;

  @override
  void initState() {
    _bloc = DepositConfirmBloc(
      widget.account,
      widget.proposal,
    );
    get.registerSingleton<DepositConfirmBloc>(_bloc);
    _bloc.load();
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<DepositConfirmBloc>();
    super.dispose();
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
          strings.depositConfirmScreenConfirmDeposit,
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
                get<ProposalsFlowBloc>().showTransactionData(
                  data,
                  Strings.of(context).stakingConfirmData,
                );
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
        child: StreamBuilder<DepositDetails?>(
            initialData: _bloc.depositDetails.value,
            stream: _bloc.depositDetails,
            builder: (context, snapshot) {
              final details = snapshot.data;

              if (details == null) {
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
                          title: strings.depositConfirmScreenDepositDetails,
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.withRowChildren(
                          title: strings.proposalVoteConfirmProposalId,
                          children: [
                            PwText(
                              widget.proposal.proposalId.toString(),
                              textAlign: TextAlign.end,
                              style: PwTextStyle.footnote,
                            ),
                            HorizontalSpacer.small(),
                            GestureDetector(
                              onTap: () async {
                                String url = _bloc.getProvUrl();
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: PwIcon(
                                  PwIcons.newWindow,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .neutralNeutral,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.fromStrings(
                          title: strings.proposalVoteConfirmTitle,
                          value: widget.proposal.title,
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.fromStrings(
                          title: strings.depositConfirmScreenCurrentDeposit,
                          value:
                              strings.hashAmount(details.sliderMin.toString()),
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.fromStrings(
                          title: strings.depositConfirmScreenTotalDeposit,
                          value: strings.hashAmount(
                              (details.amount + details.sliderMin)
                                  .toInt()
                                  .toString()),
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.fromStrings(
                          title: strings.stakingDelegateAvailableBalance,
                          value:
                              strings.hashAmount(details.hashAmount.toString()),
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.withRowChildren(
                          title: strings.depositConfirmScreenDepositAmount,
                          children: [
                            if (details.amount + details.sliderMin >
                                nHashToHash(BigInt.parse(
                                        details.proposal?.neededDeposit ?? "0"))
                                    .toDouble())
                              PwIcon(
                                PwIcons.warn,
                                color: Theme.of(context).errorColor,
                                size: 19,
                              ),
                            HorizontalSpacer.small(),
                            PwText(
                              strings.hashAmount(
                                  details.amount.toInt().toString()),
                              style: PwTextStyle.footnote,
                            )
                          ],
                        ),
                        DepositSlider(
                          max: details.sliderMax,
                          thumbColor: Theme.of(context).colorScheme.primary550,
                          onChanged: (changed) => _bloc.depositAmount = changed,
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
                      enabled: details.amount > 0 &&
                          details.amount <= details.hashAmount,
                      onPressed: () async {
                        await ModalLoadingRoute.showLoading(
                          context,
                          minDisplayTime: Duration(milliseconds: 500),
                        );
                        await _sendVote(_gasEstimate, context);
                      },
                      child: PwText(
                        strings.depositConfirmScreenConfirmDeposit,
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

  Future<void> _sendVote(
    double? gasEstimate,
    BuildContext context,
  ) async {
    try {
      final response = await _bloc.sendTransaction(gasEstimate);
      ModalLoadingRoute.dismiss(context);
      get<ProposalsFlowBloc>().showTransactionComplete(
        response,
        Strings.of(context).proposalDepositComplete,
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
