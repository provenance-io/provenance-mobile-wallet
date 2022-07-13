import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/util/invite_link_util.dart';

const inviteId = 'abc';
const coin = Coin.testNet;

void main() {
  test('Parses valid invite link', () {
    final inviteLink = createInviteLink(inviteId, coin);

    final data = parseInviteLinkData(inviteLink);
    expect(data?.inviteId, inviteId);
    expect(data?.coin, coin);
  });

  test('Parse invalid scheme returns null', () {
    final inviteLink = createInviteLink(inviteId, coin);

    final uri = Uri.parse(inviteLink);
    final invalidLink = uri.replace(scheme: 'http').toString();

    final data = parseInviteLinkData(invalidLink);
    expect(data, isNull);
  });

  test('Parse invalid host returns null', () {
    final inviteLink = createInviteLink(inviteId, coin);

    final uri = Uri.parse(inviteLink);
    final invalidLink = uri.replace(host: 'google.com').toString();

    final data = parseInviteLinkData(invalidLink);
    expect(data, isNull);
  });
}
