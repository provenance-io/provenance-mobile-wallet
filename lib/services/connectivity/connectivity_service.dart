import 'package:rxdart/rxdart.dart';

abstract class ConnectivityService {
  ValueStream<bool> get isConnected;
}
