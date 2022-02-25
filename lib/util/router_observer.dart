import 'package:flutter/material.dart';

class RouterObserver {
  factory RouterObserver() => _singleton;
  RouterObserver._internal();

  static final RouterObserver _singleton = RouterObserver._internal();

  final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

  static RouterObserver get instance => _singleton;
}
