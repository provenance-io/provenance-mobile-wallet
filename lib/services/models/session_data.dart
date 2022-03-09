import 'package:provenance_dart/wallet_connect.dart';

class SessionData {
  SessionData(
    this.walletId,
    this.peerId,
    this.remotePeerId,
    this.address,
    this.clientMeta,
  );

  final String walletId;
  final String peerId;
  final String remotePeerId;
  final String address;
  final ClientMeta clientMeta;

  // ignore: member-ordering
  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      json['walletId'] as String,
      json['peerId'] as String,
      json['remotePeerId'] as String,
      json['address'] as String,
      ClientMeta.fromJson(json['clientMeta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'walletId': walletId,
        'peerId': peerId,
        'remotePeerId': remotePeerId,
        'address': address,
        'clientMeta': clientMeta.toJson(),
      };
}
