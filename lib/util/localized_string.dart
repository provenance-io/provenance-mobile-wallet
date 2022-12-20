import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/util/strings.dart';

extension StringIdExtension on StringId {
  LocalizedString toLocalized() => LocalizedString.id(this);
}

abstract class LocalizedString {
  factory LocalizedString.id(StringId id) => LocalizedStringId(id);

  factory LocalizedString.text(String text) => LocalizedStringText(text);

  factory LocalizedString.function(
          String Function(BuildContext context) function) =>
      LocalizedStringFunction(function);

  String get(BuildContext context);
}

class LocalizedStringText implements LocalizedString {
  const LocalizedStringText(this.text);

  final String text;

  @override
  String get(BuildContext context) => text;
}

class LocalizedStringId implements LocalizedString {
  const LocalizedStringId(this.id);

  final StringId id;

  @override
  String get(BuildContext context) => _lookup[id]!.call(context);
}

class LocalizedStringFunction implements LocalizedString {
  const LocalizedStringFunction(this.function);

  final String Function(BuildContext context) function;

  @override
  String get(BuildContext context) => function(context);
}

enum StringId {
  actionListLabelUnknown,
  actionListLabelApproveSession,
  actionListLabelTransactionRequested,
  actionListLabelSignatureRequested,
  actionListSubLabelActionRequired,
  appleDiscontinuedMessage,
  googleDiscontinuedMessage,
  multiSigTransactionInitiatedNotification,
  networkProvenanceMainnet,
  networkProvenanceTestnet,
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
  StringId.networkProvenanceMainnet: (c) =>
      Strings.of(c).networkProvenanceMainnet,
  StringId.networkProvenanceTestnet: (c) =>
      Strings.of(c).networkProvenanceTestnet,
  StringId.appleDiscontinuedMessage: (c) =>
      Strings.of(c).appleDiscontinuedMessage,
  StringId.googleDiscontinuedMessage: (c) =>
      Strings.of(c).googleDiscontinuedMessage,
};
