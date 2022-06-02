import 'package:uuid/uuid.dart';

enum MultiSigInviteStatus {
  pending,
  ready,
  rejected,
}

class MultiSigCosignerResponse {
  MultiSigCosignerResponse({
    required this.status,
  });

  final MultiSigInviteStatus status;
}

class MultiSigInvite {
  MultiSigInvite({
    required this.cosignerCount,
    this.responses = const [],
  });

  final int cosignerCount;
  final List<MultiSigCosignerResponse> responses;
}

class MultiSigService {
  final _invites = <String, MultiSigInvite>{};

  Future<String> register({
    required int cosignerCount,
  }) async {
    final id = Uuid().v1().toString();
    _invites[id] = MultiSigInvite(
      cosignerCount: cosignerCount,
    );

    return id;
  }

  Future<MultiSigInvite?> getInvite({
    required String id,
  }) async {
    final invite = _invites[id];

    return invite;
  }
}
