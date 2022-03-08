import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseDeepLinkService implements DeepLinkService {
  FirebaseDeepLinkService();

  final _subscriptions = CompositeSubscription();
  final _link = BehaviorSubject<Uri>(sync: true);

  @override
  ValueStream<Uri> get link => _link;

  Future<void> init() async {
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      _link.add(initialLink.link);
    }

    FirebaseDynamicLinks.instance.onLink
        .listen((e) => _link.add(e.link))
        .addTo(_subscriptions);
  }
}
