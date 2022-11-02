import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_gas_adjustment_slider.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/deposit_confirm/deposit_confirm_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/deposit_confirm/deposit_slider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/warning_section.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DepositConfirmScreen extends StatefulWidget {
  const DepositConfirmScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DepositConfirmScreenState();
}

class _DepositConfirmScreenState extends State<DepositConfirmScreen> {
  double _gasEstimate = defaultGasAdjustment;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<DepositConfirmBloc>(context, listen: false);
    final strings = Strings.of(context);
    final _formatter = DateFormat.yMMMd('en_US');

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
                final data = bloc.getMessageJson();
                Provider.of<ProposalsBloc>(context, listen: false)
                    .showTransactionData(
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
            initialData: bloc.depositDetails.value,
            stream: bloc.depositDetails,
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
                        WarningSection(
                          title: strings.depositConfirmScreenByDepositingHASH,
                          message:
                              strings.depositConfirmScreenDepositWillBeLocked(
                                  _formatter.format(
                                      details.proposal!.depositEndTime)),
                          background: Theme.of(context).colorScheme.error,
                        ),
                        DetailsHeader(
                          title: strings.depositConfirmScreenDepositDetails,
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.withRowChildren(
                          title: strings.proposalVoteConfirmProposalId,
                          children: [
                            PwText(
                              details.proposal?.proposalId.toString() ?? "",
                              textAlign: TextAlign.end,
                              style: PwTextStyle.footnote,
                            ),
                            HorizontalSpacer.small(),
                            GestureDetector(
                              onTap: () async {
                                String url = bloc.getProvUrl();
                                if (await canLaunchUrlString(url)) {
                                  await launchUrlString(url);
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
                          value: details.proposal?.title ?? "",
                        ),
                        PwListDivider.alternate(),
                        VerticalSpacer.xxLarge(),
                        PwText(strings.depositConfirmScreenDepositAmount),
                        DepositSlider(
                          max: details.sliderMax,
                          thumbColor:
                              Theme.of(context).colorScheme.secondary350,
                          onChanged: (changed) => bloc.depositAmount = changed,
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.fromStrings(
                          title: strings.depositConfirmScreenAvailableBalance,
                          value:
                              strings.hashAmount(details.hashAmount.toString()),
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.fromStrings(
                          title: strings.depositConfirmScreenDepositNeeded,
                          value: strings.hashAmount(details
                              .proposal!.neededDepositFormatted
                              .toString()),
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.fromStrings(
                          title: strings.depositConfirmScreenCurrentDeposit,
                          value: strings.hashAmount(
                              details.currentDepositHash.toString()),
                        ),
                        PwListDivider.alternate(),
                        DetailsItem.fromStrings(
                          title: strings.depositConfirmScreenTotalDeposit,
                          value: strings.hashAmount(
                              (details.amount + details.currentDepositHash)
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
                            if (details.amount + details.currentDepositHash >
                                details.neededDepositHash)
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
                          onChanged: (changed) => bloc.depositAmount = changed,
                        ),
                        PwListDivider.alternate(),
                        PwGasAdjustmentSlider(
                          title: strings.stakingConfirmGasAdjustment,
                          startingValue: defaultGasAdjustment,
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
      final response =
          await Provider.of<DepositConfirmBloc>(context, listen: false)
              .sendTransaction(gasEstimate);
      ModalLoadingRoute.dismiss(context);
      Provider.of<ProposalsBloc>(context, listen: false)
          .showTransactionComplete(
        response,
        Strings.of(context).proposalDepositComplete,
      );
    } catch (err) {
      await _showErrorModal(err, context);
    }
  }

  Future<void> _showErrorModal(Object error, BuildContext context) async {
    ModalLoadingRoute.dismiss(context);

    await PwDialog.showError(
      context: context,
      error: error,
    );
  }
}
