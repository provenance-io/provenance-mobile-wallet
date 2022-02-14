import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/pw_design.dart';

extension Spacing on double {
  static const xSmall = 4.0;
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const xLarge = 24.0;
  static const xxLarge = 32.0;
  static const largeX3 = 40.0;
  static const largeX4 = 48.0;
  static const largeX5 = 64.0;
  static const largeX6 = 80.0;
}

class VerticalSpacer extends StatelessWidget {
  const VerticalSpacer._(
    this._height, {
    Key? key,
  }) : super(key: key);

  const VerticalSpacer.xSmall({Key? key})
      : this._(
          Spacing.xSmall,
          key: key,
        );
  const VerticalSpacer.small({Key? key})
      : this._(
          Spacing.small,
          key: key,
        );
  const VerticalSpacer.medium({Key? key})
      : this._(
          Spacing.medium,
          key: key,
        );
  const VerticalSpacer.large({Key? key})
      : this._(
          Spacing.large,
          key: key,
        );
  const VerticalSpacer.xLarge({Key? key})
      : this._(
          Spacing.xLarge,
          key: key,
        );
  const VerticalSpacer.xxLarge({Key? key})
      : this._(
          Spacing.xxLarge,
          key: key,
        );
  const VerticalSpacer.largeX3({Key? key})
      : this._(
          Spacing.largeX3,
          key: key,
        );
  const VerticalSpacer.largeX4({Key? key})
      : this._(
          Spacing.largeX4,
          key: key,
        );
  const VerticalSpacer.largeX5({Key? key})
      : this._(
          Spacing.largeX5,
          key: key,
        );
  const VerticalSpacer.largeX6({Key? key})
      : this._(
          Spacing.largeX6,
          key: key,
        );
  const VerticalSpacer.custom({Key? key, required double spacing})
      : this._(
          spacing,
          key: key,
        );

  final double? _height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: _height);
  }
}

class HorizontalSpacer extends StatelessWidget {
  const HorizontalSpacer._(
    this._width, {
    Key? key,
  }) : super(key: key);

  const HorizontalSpacer.xSmall({Key? key})
      : this._(
          Spacing.xSmall,
          key: key,
        );
  const HorizontalSpacer.small({Key? key})
      : this._(
          Spacing.small,
          key: key,
        );
  const HorizontalSpacer.medium({Key? key})
      : this._(
          Spacing.medium,
          key: key,
        );
  const HorizontalSpacer.large({Key? key})
      : this._(
          Spacing.large,
          key: key,
        );
  const HorizontalSpacer.xLarge({Key? key})
      : this._(
          Spacing.xLarge,
          key: key,
        );
  const HorizontalSpacer.xxLarge({Key? key})
      : this._(
          Spacing.xxLarge,
          key: key,
        );
  const HorizontalSpacer.largeX3({Key? key})
      : this._(
          Spacing.largeX3,
          key: key,
        );
  const HorizontalSpacer.largeX4({Key? key})
      : this._(
          Spacing.largeX4,
          key: key,
        );
  const HorizontalSpacer.largeX5({Key? key})
      : this._(
          Spacing.largeX5,
          key: key,
        );
  const HorizontalSpacer.largeX6({Key? key})
      : this._(
          Spacing.largeX6,
          key: key,
        );
  const HorizontalSpacer.custom({Key? key, required double spacing})
      : this._(
          spacing,
          key: key,
        );

  final double? _width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _width);
  }
}
