import 'package:rxdart/rxdart.dart';

abstract class DeepLinkService {
  ValueStream<Uri> get link;
}
