import 'package:http/http.dart' as http;

import 'logs/logging.dart';

Future<String?> tryFollowRedirect(String? uri) async {
  if (uri == null) {
    return null;
  }

  var result = Uri.tryParse(uri);
  if (result == null || !result.hasScheme || !result.hasAuthority) {
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
    Log.instance.error(
      'Failed to follow redirect',
      tag: 'invite_link_util',
      error: e,
    );
  } finally {
    baseClient.close();
  }

  return result.toString();
}
