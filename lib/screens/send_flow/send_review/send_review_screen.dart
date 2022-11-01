import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send_success/send_success_screen.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provenance_wallet/util/transaction_error_util.dart';
import 'package:provider/provider.dart';

class SendReviewCell extends StatelessWidget {
  const SendReviewCell(
    this.label,
    this.value, {
    Key? key,
  }) : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Spacing.large,
        horizontal: Spacing.xLarge,
      ),
      child: Row(
        children: [
          PwText(label),
          Expanded(
            child: PwText(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class SendReviewScreen extends StatelessWidget {
  const SendReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).sendReviewTitle,
        leadingIcon: PwIcons.back,
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          Spacing.large,
        ),
        child: SendReviewPage(),
      ),
    );
  }
}

class SendReviewPage extends StatelessWidget {
  const SendReviewPage({
    Key? key,
  }) : super(key: key);

  static final keySendButton = ValueKey('$SendReviewPage.send_button');

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SendReviewBloc>(context);

    return StreamBuilder<SendReviewBlocState>(
      stream: bloc.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final state = snapshot.data!;

        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  VerticalSpacer.large(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.large,
                    ),
                    child: PwText(
                      Strings.of(context).sendReviewConfirmYourInfo,
                      style: PwTextStyle.title,
                    ),
                  ),
                  VerticalSpacer.large(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.large,
                    ),
                    child: PwText(
                      Strings.of(context).sendReviewSendPleaseReview,
                      style: PwTextStyle.body,
                    ),
                  ),
                  VerticalSpacer.largeX4(),
                  SendReviewCell(
                    Strings.of(context).sendTo,
                    abbreviateAddress(state.receivingAddress),
                  ),
                  PwDivider(
                    indent: Spacing.xLarge,
                    endIndent: Spacing.xLarge,
                  ),
                  SendReviewCell(
                    Strings.of(context).sendReviewSending,
                    "${state.sendingAsset.displayAmount} ${state.sendingAsset.displayDenom}",
                  ),
                  PwDivider(
                    indent: Spacing.xLarge,
                    endIndent: Spacing.xLarge,
                  ),
                  SendReviewCell(
                    Strings.of(context).sendReviewTransactionFee,
                    state.fee.displayAmount,
                  ),
                  PwDivider(
                    indent: Spacing.xLarge,
                    endIndent: Spacing.xLarge,
                  ),
                  SendReviewCell(
                    Strings.of(context).sendReviewTotal,
                    state.total,
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  PwButton(
                    key: SendReviewPage.keySendButton,
                    child: PwText(
                      Strings.of(context).sendReviewSendButtonTitle,
                      style: PwTextStyle.bodyBold,
                    ),
                    onPressed: () async {
                      await _sendClicked(
                        context,
                        bloc,
                        state.total,
                        state.receivingAddress,
                      );
                    },
                  ),
                  VerticalSpacer.large(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendClicked(BuildContext context, SendReviewBloc bloc,
      String total, String addressTo) async {
    QueuedTx? queuedTx;

    ModalLoadingRoute.showLoading(
      context,
      minDisplayTime: Duration(milliseconds: 500),
    );

    try {
      queuedTx = await bloc.doSend();
    } catch (e, s) {
      logError(
        'Send failed',
        error: e,
        stackTrace: s,
      );

      PwDialog.showError(
        context: context,
        error: e,
      );
    } finally {
      ModalLoadingRoute.dismiss(context);
    }

    if (queuedTx != null) {
      switch (queuedTx.kind) {
        case QueuedTxKind.executed:
          final executedTx = queuedTx as ExecutedTx;
          final responseCode = executedTx.result.response.txResponse.code;
          if (responseCode == 0) {
            await showDialog(
              barrierColor: Colors.transparent,
              useSafeArea: true,
              context: context,
              builder: (context) => SendSuccessScreen(
                date: DateTime.now(),
                totalAmount: total,
                addressTo: abbreviateAddress(addressTo),
              ),
            );

            await bloc.complete();
          } else {
            logError(
              'Send failed',
              error: queuedTx.result.response.txResponse.rawLog,
            );

            PwDialog.showError(
              context: context,
              message: errorMessage(
                context,
                executedTx.result.response.txResponse.codespace,
                executedTx.result.response.txResponse.code,
              ),
            );
          }
          break;
        case QueuedTxKind.scheduled:
          await PwDialog.showFull(
            context: context,
            title: Strings.of(context).multiSigTransactionInitiatedTitle,
            message: Strings.of(context).multiSigTransactionInitiatedMessage,
            icon: Image.asset(
              Assets.imagePaths.transactionComplete,
              height: 80,
              width: 80,
            ),
            dismissButtonText:
                Strings.of(context).multiSigTransactionInitiatedDone,
          );
          await bloc.complete();
          break;
      }
    }
  }
}
