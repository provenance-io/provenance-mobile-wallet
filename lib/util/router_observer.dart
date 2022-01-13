import 'package:flutter/material.dart';

class RouterObserver {
  factory RouterObserver() => _singleton;
  RouterObserver._internal();

  static final RouterObserver _singleton = RouterObserver._internal();

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  static RouterObserver get instance => _singleton;
}
