import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/screens/landing/landing.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provenance_wallet/util/router_observer.dart';

void main() {
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
