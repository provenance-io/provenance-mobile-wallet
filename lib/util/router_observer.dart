import 'package:flutter/material.dart';

class RouterObserver {
  static final RouterObserver _singleton = RouterObserver._internal();

  factory RouterObserver() => _singleton;
  static RouterObserver get instance => _singleton;
  RouterObserver._internal();

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
}
