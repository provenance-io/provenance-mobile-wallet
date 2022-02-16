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

class SendFlowState
    extends FlowBaseState<SendFlow>
    implements SendBlocNavigator,
              SendAmountBlocNavigator
{
  final  _navigatorKey = GlobalKey<NavigatorState>();

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
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.grey,
      appBarTheme: theme.appBarTheme.copyWith(
        color: Colors.black,
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          color: Colors.white
        ),
      ),
      colorScheme: theme.colorScheme.copyWith(
        primary: Colors.white,
      ),
      textTheme: theme.textTheme.apply(
          displayColor: Colors.white,
          bodyColor: Colors.white,
          decorationColor: Colors.white,
      ),
      iconTheme: theme.iconTheme.copyWith(
        color: borderColor,
      ),
      buttonTheme: theme.buttonTheme.copyWith(
        colorScheme: theme.buttonTheme.colorScheme?.copyWith(
          primary: Color.fromARGB(255, 0x2E, 0x69, 0xE2,),
        ),
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
        this
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
      context: context,
      builder: (context) {
        return ErrorDialog(
          error: "Not Implemented",
        );
      },);
  }

  Future<void> showRecentSendDetails(RecentAddress recentAddress) {
    return showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            error: Strings.NotImplementedMessage,
          );
        },);

  }

  /* SendAmountBlocNavigator */

  @override
  Future<void> showReviewSend(String amountToSend, String fee, String note) {
    // return Future.value();
    completeFlow([ _asset, _receivingAddress, amountToSend, fee ]);
    return Future.value();
  }
}
