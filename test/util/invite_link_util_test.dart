import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/util/invite_link_util.dart';

void main() {
  test('Parses valid invite link', () {
    const inviteId = 'abc';
    final inviteLink = createInviteLink(inviteId);

    final actual = parseInviteId(inviteLink);
    expect(actual, inviteId);
  });

  test('Parse invalid scheme returns null', () {
    const inviteId = 'abc';
    final inviteLink = createInviteLink(inviteId);

    final uri = Uri.parse(inviteLink);
    final invalidLink = uri.replace(scheme: 'http').toString();

    final actual = parseInviteId(invalidLink);
    expect(actual, isNull);
  });

  test('Parse invalid host returns null', () {
    const inviteId = 'abc';
    final inviteLink = createInviteLink(inviteId);

    final uri = Uri.parse(inviteLink);
    final invalidLink = uri.replace(host: 'google.com').toString();

    final actual = parseInviteId(invalidLink);
    expect(actual, isNull);
  });

  test('Query parameters are ignored', () {
    const inviteId = 'abc';
    final inviteLink = createInviteLink(inviteId);

    final uri = Uri.parse(inviteLink);
    final linkWithQuery = uri.replace(queryParameters: {
      'a': 'b',
      'c': 'd',
    }).toString();

    final actual = parseInviteId(linkWithQuery);
    expect(actual, inviteId);
  });
}
