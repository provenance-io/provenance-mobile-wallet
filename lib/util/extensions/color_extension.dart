import 'package:flutter/widgets.dart';

extension ColorExtension on Color {
  Color asDisabled() => withOpacity(.5);
}
