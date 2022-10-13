part of 'localized_string.dart';

// TODO-Roy: Generate StringId and _lookup from app_en.arb
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
