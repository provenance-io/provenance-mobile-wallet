import 'package:provenance_wallet/common/pw_design.dart';

abstract class PwError {
  PwError._();

  String toLocalizedString(BuildContext context);
}
