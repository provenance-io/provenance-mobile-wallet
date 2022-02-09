import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';

enum WalletConnectionServiceStatus {
  created,
  disconnected,
  connecting,
  connected
}

class RemoteClientDetails {
  RemoteClientDetails(this.id, this.description, this.url, this.name, this.icons,);
  final String id;
  final String description;
  final Uri? url;
  final String name;
  final List<String> icons;
}

abstract class WalletConnectService {
  Stream<SendRequest> get sendRequest;

  Stream<SignRequest> get signRequest;

  Stream<RemoteClientDetails> get sessionRequest;

  Stream<WalletConnectionServiceStatus> get status;

  String get address;

  Future<bool> disconnectSession();

  Future<bool> connectWallet();

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  });

  Future<bool> sendMessageFinish({
    required requestId,
    required bool allowed,
  });

  Future<bool> approveSession({
    required String requestId,
    required bool allowed,
  });
}
