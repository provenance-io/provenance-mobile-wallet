// ignore_for_file: member-ordering

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provenance_wallet/common/pw_design.dart';

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

typedef LocalizedString = String Function(BuildContext context);
