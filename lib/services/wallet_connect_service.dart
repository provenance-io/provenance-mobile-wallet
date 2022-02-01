import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';

abstract class WalletConnectService {
  abstract final Stream<SendRequest> sendRequest;

  abstract final Stream<SignRequest> signRequest;

  abstract final Stream<String> connected;

  abstract final Stream disconnected;

  Future<bool> disconnectSession();

  Future<bool> connectWallet(String qrData);

  Future<bool> configureServer();

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  });

  Future<bool> sendMessageFinish({
    required requestId,
    required bool allowed,
  });

  Future<bool> isValidWalletConnectData(String qrData);
}
