import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';

class WalletConnectTransactionRequest {
  WalletConnectTransactionRequest({
    required this.details,
    required this.clientDetails,
  });

  final SendRequest details;
  final RemoteClientDetails clientDetails;
}
