import 'package:provenance_blockchain_wallet/common/flow_base.dart';
import 'package:provenance_blockchain_wallet/common/pw_design.dart';
import 'package:provenance_blockchain_wallet/dialogs/error_dialog.dart';
import 'package:provenance_blockchain_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_blockchain_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_blockchain_wallet/screens/send_flow/send/send_bloc.dart';
import 'package:provenance_blockchain_wallet/screens/send_flow/send/send_screen.dart';
import 'package:provenance_blockchain_wallet/screens/send_flow/send_amount/send_amount_bloc.dart';
import 'package:provenance_blockchain_wallet/screens/send_flow/send_amount/send_amount_screen.dart';
import 'package:provenance_blockchain_wallet/screens/send_flow/send_review/send_review_bloc.dart';
import 'package:provenance_blockchain_wallet/screens/send_flow/send_review/send_review_screen.dart';
import 'package:provenance_blockchain_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_blockchain_wallet/services/models/wallet_details.dart';
import 'package:provenance_blockchain_wallet/services/price_service/price_service.dart';
import 'package:provenance_blockchain_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/transaction_handler.dart';
import 'package:provenance_blockchain_wallet/util/get.dart';
import 'package:provenance_blockchain_wallet/util/strings.dart';

class SendFlow extends FlowBase {
  const SendFlow(this.walletDetails, {Key? key}) : super(key: key);

  final WalletDetails walletDetails;
  @override
  State<StatefulWidget> createState() => SendFlowState();
}

class SendFlowState extends FlowBaseState<SendFlow>
    implements SendBlocNavigator, SendAmountBlocNavigator, SendReviewNaviagor {
  String? _receivingAddress;
  SendAsset? _asset;

  @override
  void initState() {
    super.initState();
    get.registerLazySingleton<SendBloc>(() {
      return SendBloc(
        widget.walletDetails.coin,
        widget.walletDetails.address,
        get<AssetService>(),
        get<PriceService>(),
        get<TransactionService>(),
        this,
      );
    });
  }

  @override
  void dispose() {
    get.unregister<SendBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const borderColor = Colors.white;
    final borderRadius = BorderRadius.circular(5);
    final borderSide = BorderSide(
      width: 1,
      color: borderColor,
    );

    final copy = theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
      ),
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

  @override
  Future<String?> scanAddress() {
    return showPage((context) => QRCodeScanner());
  }

  @override
  Future<void> showSelectAmount(String address, SendAsset asset) {
    _asset = asset;
    _receivingAddress = address;

    final bloc = SendAmountBloc(
      widget.walletDetails,
      _receivingAddress!,
      _asset!,
      get<PriceService>(),
      this,
    )..init();

    get.registerSingleton(bloc);

    return showPage((context) => SendAmountScreen())
        .whenComplete(() => get.unregister<SendAmountBloc>());
  }

  @override
  Widget createStartPage() {
    return SendScreen();
  }

  @override
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

  /* SendAmountBlocNavigator */

  @override
  Future<void> showReviewSend(
    SendAsset amountToSend,
    MultiSendAsset fee,
    String note,
  ) {
    final bloc = SendReviewBloc(
      widget.walletDetails,
      get<TransactionHandler>(),
      _receivingAddress!,
      amountToSend,
      fee,
      note,
      this,
    );

    get.registerSingleton(bloc);

    return showPage((context) => SendReviewScreen())
        .whenComplete(() => get.unregister<SendReviewBloc>());
  }

  /* SendReviewNaviagor */

  @override
  void complete() {
    completeFlow(null);
  }
}
