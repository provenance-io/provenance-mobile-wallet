import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/firebase_options.dart';
import 'package:provenance_wallet/screens/landing/landing.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provenance_wallet/util/router_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Figure Merchant',
      theme: FigurePayThemeData.themeData,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: [RouterObserver.instance.routeObserver],
      home: Landing(),
    );
  }
}
