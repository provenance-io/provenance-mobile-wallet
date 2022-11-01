import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/util/strings.dart';

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

enum StringId {
  actionListLabelUnknown,
  actionListLabelApproveSession,
  actionListLabelTransactionRequested,
  actionListLabelSignatureRequested,
  actionListSubLabelActionRequired,
  multiSigTransactionInitiatedNotification,
}

final _lookup = {
  StringId.actionListLabelUnknown: (c) => Strings.of(c).actionListLabelUnknown,
  StringId.actionListLabelApproveSession: (c) =>
      Strings.of(c).actionListLabelApproveSession,
  StringId.actionListLabelTransactionRequested: (c) =>
      Strings.of(c).actionListLabelTransactionRequested,
  StringId.actionListLabelSignatureRequested: (c) =>
      Strings.of(c).actionListLabelSignatureRequested,
  StringId.actionListSubLabelActionRequired: (c) =>
      Strings.of(c).actionListSubLabelActionRequired,
  StringId.multiSigTransactionInitiatedNotification: (c) =>
      Strings.of(c).multiSigTransactionInitiatedNotification,
};
