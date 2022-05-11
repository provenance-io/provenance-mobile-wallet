import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:rxdart/rxdart.dart';

class DisabledDeepLinkService implements DeepLinkService {
  @override
  ValueStream<Uri> get link => BehaviorSubject();
}
