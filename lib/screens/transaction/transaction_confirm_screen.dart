import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/transaction/transaction_data_screen.dart';
import 'package:provenance_wallet/screens/transaction/transaction_message_default.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/util/messages/message_field_name.dart';
import 'package:provenance_wallet/util/strings.dart';

typedef MessageBuilder = Widget Function(
  String requestId,
  RemoteClientDetails clientDetails,
  String? message,
  Map<String, dynamic>? data,
  int? fees,
);

enum TransactionConfirmKind {
  approve,
  notify,
}

class TransactionConfirmScreen extends StatefulWidget {
  const TransactionConfirmScreen({
    required this.kind,
    required this.title,
    required this.requestId,
    required this.clientDetails,
    this.subTitle,
    this.message,
    this.data,
    this.fees,
    Key? key,
  }) : super(key: key);

  final TransactionConfirmKind kind;
  final String title;
  final String requestId;
  final RemoteClientDetails clientDetails;
  final String? subTitle;
  final String? message;
  final List<Map<String, dynamic>>? data;
  final int? fees;

  @override
  State<StatefulWidget> createState() => TransactionConfirmScreenState();
}

class TransactionConfirmScreenState extends State<TransactionConfirmScreen> {
  final _builders = <Type, MessageBuilder>{
    // Add a builder to override a specific message type.
  };

  final PageController _pageController = PageController();
  final ValueNotifier<int> _pageIndexNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      _pageIndexNotifier.value = _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.neutral750,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.neutral750,
          elevation: 0.0,
          centerTitle: true,
          title: PwText(
            widget.title,
            color: PwColor.neutralNeutral,
            style: PwTextStyle.subhead,
          ),
          automaticallyImplyLeading: false,
          actions: [
            ValueListenableBuilder<int>(
              valueListenable: _pageIndexNotifier,
              builder: (
                context,
                page,
                child,
              ) {
                final data = widget.data?[page];

                if (!(data?.keys.contains(MessageFieldName.type) ?? false)) {
                  return Container();
                }

                return MaterialButton(
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      pageBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                      ) {
                        return TransactionDataScreen(
                          data: data!,
                        );
                      },
                    );
                  },
                  child: PwText(
                    Strings.transactionDataButton,
                    color: PwColor.primaryP500,
                    style: PwTextStyle.body,
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.subTitle != null)
              Container(
                margin: EdgeInsets.only(
                  left: Spacing.xxLarge,
                  top: Spacing.xxLarge,
                ),
                alignment: Alignment.centerLeft,
                child: PwText(
                  widget.subTitle!,
                  style: PwTextStyle.bodyBold,
                ),
              ),
            VerticalSpacer.xxLarge(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final dataItem = widget.data![index];

                  return _buildMessage(dataItem);
                },
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: _pageIndexNotifier,
              builder: (
                context,
                value,
                child,
              ) {
                return Container(
                  margin: EdgeInsets.only(
                    top: Spacing.large,
                    bottom: Spacing.xxLarge,
                  ),
                  child: PwText(
                    "${value + 1} / ${widget.data?.length ?? 0}",
                  ),
                );
              },
            ),
            Container(
              padding: EdgeInsets.only(
                left: Spacing.large,
                right: Spacing.large,
                bottom: Spacing.largeX4,
              ),
              color: Theme.of(context).colorScheme.neutral750,
              child: widget.kind == TransactionConfirmKind.approve
                  ? _ApproveActions()
                  : _NotifyActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> data) {
    final builder = _builders[data.runtimeType];

    if (builder == null) {
      return TransactionMessageDefault(
        requestId: widget.requestId,
        clientDetails: widget.clientDetails,
        message: widget.message,
        data: data,
        fees: widget.fees,
      );
    }

    return builder.call(
      widget.requestId,
      widget.clientDetails,
      widget.message,
      data,
      widget.fees,
    );
  }
}

class _NotifyActions extends StatelessWidget {
  const _NotifyActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PwTextButton.primaryAction(
      context: context,
      onPressed: () {
        Navigator.of(context).pop();
      },
      text: Strings.transactionBackToDashboard,
    );
  }
}

class _ApproveActions extends StatelessWidget {
  const _ApproveActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PwTextButton.primaryAction(
          context: context,
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          text: Strings.transactionApprove,
        ),
        VerticalSpacer.large(),
        PwTextButton.secondaryAction(
          context: context,
          text: Strings.transactionDecline,
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}
