import 'package:flutter/material.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/home_screen.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  late LocalAuthHelper _localAuthHelper;

  @override
  void initState() {
    super.initState();
    _localAuthHelper = get<LocalAuthHelper>();
    _localAuthHelper.auth(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthStatus>(
      stream: _localAuthHelper.status,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return Container();
        }

        return (snapshot.data == AuthStatus.authenticated)
            ? Provider<HomeBloc>(
                lazy: true,
                create: (context) {
                  return HomeBloc();
                },
                dispose: (_, bloc) {
                  bloc.onDispose();
                },
                child: HomeScreen())
            : LandingScreen();
      },
    );
  }
}
