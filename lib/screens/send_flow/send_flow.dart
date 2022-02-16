import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_screen.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class SendFlow extends FlowBase {
  @override
  State<StatefulWidget> createState() => SendFlowState();
}

class SendFlowState
    extends FlowBaseState<SendFlow>
    implements SendBlocNavigator
{
  final  _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

     get.registerSingleton<SendBloc>(SendBloc(this));
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

  Future<void> showSelectAmount(String address, Asset asset) {
    completeFlow([ address, asset ]);
    return Future.value();
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
}
