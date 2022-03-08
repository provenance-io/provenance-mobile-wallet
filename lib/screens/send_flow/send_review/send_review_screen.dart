import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
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
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Row(
        children: [
          PwText(label),
          Expanded(
            child: PwText(
              value,
              textAlign: TextAlign.end,
              style: PwTextStyle.caption,
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
      appBar: AppBar(
        title: PwText(Strings.sendReviewTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.medium,
          horizontal: Spacing.medium,
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
                  const PwText(
                    Strings.sendReviewConfirmYourInfo,
                    style: PwTextStyle.h4,
                  ),
                  VerticalSpacer.large(),
                  const PwText(
                    Strings.sendReviewSendPleaseReview,
                    style: PwTextStyle.body,
                  ),
                  VerticalSpacer.large(),
                  SendReviewCell("To", state.receivingAddress),
                  PwDivider(),
                  SendReviewCell(
                    "Sending",
                    "${state.sendingAsset.displayAmount} ${state.sendingAsset.displayDenom}",
                  ),
                  PwDivider(),
                  SendReviewCell(
                    "Transaction Fee",
                    state.fee.displayAmount,
                  ),
                  PwDivider(),
                  SendReviewCell("Total", state.total),
                  Expanded(
                    child: Container(),
                  ),
                  PwButton(
                    child: PwText(Strings.sendReviewSendButtonTitle),
                    onPressed: _sendClicked,
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

  void _sendClicked() {
    _bloc!.doSend().then((_) {
      PwDialog.showMessage(
        context,
        message: "Success",
        closeText: "Ok",
      ).then((value) => _bloc!.complete());
    }).catchError((err) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            error: err.toString(),
          );
        },
      );
    });
  }
}
