// ignore_for_file: member-ordering

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provenance_wallet/common/pw_design.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String formatNumber() {
    var sections = split('.');
    sections[0] = sections[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return sections.join('.');
  }
}

class Strings {
  // For devs only
  static const notImplementedMessage = "Not Implemented";

  // Pronouns, or no translation available
  static const chainMainNetName = 'Mainnet';
  static const chainTestNetName = 'Testnet';

  static const transactionDenomHash = 'Hash';
  static const displayHASH = "HASH";

  static const dotSeparator = "•";

  // Import for 'AppLocalizations' doesn't show up in the autocomplete,
  // so this makes it easier to use localizations.
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
}
