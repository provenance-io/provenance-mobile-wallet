import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/util/strings.dart';

part 'localized_string.g.dart';

extension StringIdExtension on StringId {
  LocalizedString toLocalized() => LocalizedString.id(this);
}

class LocalizedString {
  LocalizedString(this.get);

  LocalizedString.id(StringId id)
      : get = ((context) => _lookup[id]!.call(context));

  LocalizedString.text(String text) : get = ((context) => text);

  final String Function(BuildContext context) get;
}
