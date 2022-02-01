import 'dart:async';

import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/wallet_connect_service.dart';
import 'package:rxdart/subjects.dart';

class SampleWalletConnectService implements WalletConnectService {
  final _sendRequest = PublishSubject<SendRequest>();
  final _signRequest = PublishSubject<SignRequest>();
  final _connected = PublishSubject<String>();
  final _disconnected = PublishSubject();

  Stream<SendRequest> get sendRequest => _sendRequest.stream;

  Stream<SignRequest> get signRequest => _signRequest.stream;

  Stream<String> get connected => _connected.stream;

  Stream get disconnected => _disconnected.stream;

  Future<bool> disconnectSession() async {
    return false;
  }

  Future<bool> connectWallet(String qrData) async {
    return false;
  }

  Future<bool> configureServer() async {
    return false;
  }

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  }) async {
    return false;
  }

  Future<bool> sendMessageFinish({
    required requestId,
    required bool allowed,
  }) async {
    return false;
  }

  Future<bool> isValidWalletConnectData(String qrData) async {
    return false;
  }
}
