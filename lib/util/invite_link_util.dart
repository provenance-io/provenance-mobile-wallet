import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:provenance_wallet/util/extensions/iterable_extensions.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

const _origin = 'https://provenance.io';
const _segment = 'invite';
const _base = '$_origin/$_segment/';

String createInviteLink(String inviteId) {
  return '$_base$inviteId';
}

String? parseInviteId(String inviteLink) {
  String? inviteId;

  final uri = Uri.tryParse(inviteLink);
  final origin = uri?.origin;
  final segments = uri?.pathSegments;
  final segment = segments?.firstOrNull;

  if (origin == _origin && segment == _segment) {
    inviteId = segments?.elementAtOrNull(1);
  }

  return inviteId;
}

Future<String?> tryFollowRedirect(String? uri) async {
  if (uri == null) {
    return null;
  }

  var result = Uri.tryParse(uri);
  if (result == null) {
    return null;
  }

  final baseClient = http.Client();

  try {
    final request = http.Request('Get', result)..followRedirects = false;

    final response = await baseClient.send(request);
    final location = response.headers['location'];
    if (location != null) {
      result = Uri.tryParse(location);
    }
  } on Exception catch (e) {
    logStatic('invite_link_util', Level.debug, 'Failed to follow redirect: $e');
  } finally {
    baseClient.close();
  }

  return result.toString();
}
