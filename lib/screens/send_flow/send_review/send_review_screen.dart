import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send_success/send_success_screen.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';

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

class SendReviewPage extends StatefulWidget {
  const SendReviewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SendReviewPageState();
}

class SendReviewPageState extends State<SendReviewPage> {
  SendReviewBloc? _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = get<SendReviewBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SendReviewBlocState>(
      stream: _bloc!.stream,
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
                    child: PwText(
                      Strings.of(context).sendReviewSendButtonTitle,
                      style: PwTextStyle.bodyBold,
                    ),
                    onPressed: () async {
                      ModalLoadingRoute.showLoading(
                        context,
                        minDisplayTime: Duration(milliseconds: 500),
                      );
                      _sendClicked(state.total, state.receivingAddress);
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

  Future<void> _sendClicked(String total, String addressTo) async {
    ScheduleTxResponse? response;
    try {
      response = await _bloc!.doSend();
    } catch (e) {
      logError('Send failed', error: e);

      await showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            error: e.toString(),
          );
        },
      );
    } finally {
      ModalLoadingRoute.dismiss(context);
    }

    // TODO-Roy: Handle fail and handle scheduled

    if (response?.result != null) {
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

      await _bloc!.complete();
    }
  }
}
