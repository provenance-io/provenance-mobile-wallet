import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_screen.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class SendFlow extends FlowBase {
  @override
  State<StatefulWidget> createState() => SendFlowState();
}

class SendFlowState extends FlowBaseState<SendFlow>
    implements SendBlocNavigator, SendAmountBlocNavigator {
  final _navigatorKey = GlobalKey<NavigatorState>();

  String? _receivingAddress;
  SendAsset? _asset;

  @override
  void initState() {
    super.initState();
    get.registerLazySingleton<SendBloc>(() => SendBloc(this));
  }

  @override
  void dispose() {
    get.unregister<SendBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = Colors.white;
    final borderRadius = BorderRadius.circular(5);
    final borderSide = BorderSide(
      width: 1,
      color: borderColor,
    );

    final copy = theme.copyWith(
      canvasColor: Colors.grey,
      iconTheme: theme.iconTheme.copyWith(
        color: borderColor,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: borderSide,
        ),
        hintStyle: TextStyle(color: borderColor),
        suffixStyle: TextStyle(color: borderColor),
        counterStyle: TextStyle(color: borderColor),
      ),
    );

    return Theme(
      data: copy,
      child: super.build(context),
    );
  }

  /* SendBlocNavigator */

  Future<String?> scanAddress() {
    return showPage((context) => QRCodeScanner());
  }

  Future<void> showSelectAmount(String address, SendAsset asset) {
    _asset = asset;
    _receivingAddress = address;

    final bloc = SendAmountBloc(
      _receivingAddress!,
      _asset!,
      this,
    )..init();

    get.registerSingleton(bloc);

    return showPage((context) => SendAmountScreen())
        .whenComplete(() => get.unregister<SendAmountBloc>());
  }

  Widget createStartPage() {
    return SendScreen();
  }

  Future<void> showAllRecentSends() {
    return showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return ErrorDialog(
          error: Strings.notImplementedMessage,
        );
      },
    );
  }

  Future<void> showRecentSendDetails(RecentAddress recentAddress) {
    return showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return ErrorDialog(
          error: Strings.notImplementedMessage,
        );
      },
    );
  }

  /* SendAmountBlocNavigator */

  @override
  Future<void> showReviewSend(
    String amountToSend,
    String fee,
    String note,
  ) {
    // return Future.value();
    completeFlow([
      _asset,
      _receivingAddress,
      amountToSend,
      fee,
    ]);

    return Future.value();
  }
}
