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
    return AppLocalizations.of(context);
  }

  static String dashboardConnectionRequestDetails(
    BuildContext context,
    String name,
  ) =>
      "${AppLocalizations.of(context).dashboardConnectionRequestAllowConnectionTo} $name";

  static String numAssets(
    BuildContext context,
    int numAssets,
  ) =>
      "$numAssets ${Strings.of(context).numAssets}${numAssets != 1 ? "s" : ""}";

  static String accountLinkedTo(
    BuildContext context,
    String name,
  ) =>
      "${Strings.of(context).accountLinkedTo} '$name'";

  static String multiSigInviteReviewLandingDesc(
    BuildContext context,
    String accountName,
  ) =>
      '${Strings.of(context).multiSigInviteReviewLandingDesc} "$accountName" ${Strings.of(context).multiSigInviteReviewLandingMultiSigAccount}';

  static String recoverPassphraseNetwork(BuildContext context, String name) =>
      '${Strings.of(context).recoverPassphraseNetwork} $name';

  static String recoverPassphraseWord(BuildContext context, int number) =>
      '${Strings.of(context).recoverPassphraseWord} $number';

  static String selectWordIndex(
    BuildContext context,
    String index,
  ) =>
      '${Strings.of(context).selectWord} #$index';

  static String displayDenomFormatted(
    BuildContext context,
    String displayDenom,
  ) =>
      "$displayDenom ${Strings.of(context).displayDelegated}";

  static String displayDelegatorsWithCommission(
    BuildContext context,
    int delegators,
    String commission,
  ) =>
      "$delegators ${Strings.of(context).displayDelegators} $dotSeparator $commission ${Strings.of(context).displayCommission}";

  // TODO: The delegation type needs to be localized too.
  static String stakingSuccessSuccessful(
          BuildContext context, String delegationType) =>
      '$delegationType ${Strings.of(context).stakingSuccessSuccessful}';

  static String stakingConfirmHashAmount(String amount) =>
      '$amount ${Strings.displayHASH}';

  static String proposalsScreenVoted(
          BuildContext context, String formattedVote) =>
      "${Strings.of(context).proposalsScreenVoted} $formattedVote";

  static String proposalDetailsTitle(BuildContext context, int proposalId) =>
      "${Strings.of(context).proposalDetailsTitle} $proposalId";

  static String proposalDetailsDepositsHash(
    String deposited,
    String depositPercentage,
  ) =>
      "$deposited ${Strings.displayHASH} ($depositPercentage)";

  static String proposalDetailsHashNeeded(double needed) =>
      "$needed ${Strings.displayHASH}";

  // TODO: Remove these. Everything was requiring BuildContext
  // TODO: and I'm not sure that's what we want. These Strings have
  // TODO: already been localized, so we just need to remove them.

  static const actionListAction = "Action";
  static const actionListActions = "Actions";
  static const actionListLabelApproveSession = 'Approve Session';
  static const actionListLabelSignatureRequested = 'Signature Requested';
  static const actionListLabelTransactionRequested = 'Transaction Requested';
  static const actionListLabelUnknown = 'Unknown';
  static const actionListSubLabelActionRequired = 'Action Required';

  static const required = 'Required';
  static const sendAmountErrorInsufficient = "Insufficient";
  static const sendAmountErrorTooManyDecimalPlaces = "too many decimal places";
  static const sendAmountErrorGasEstimateNotReady =
      "The estimated fee is not ready";
}
