import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/pw_design.dart';

extension Spacing on double {
  /// 4 px
  static const xSmall = 4.0;

  /// 8 px
  static const small = 8.0;

  /// 12 px
  static const medium = 12.0;

  /// 16 px
  static const large = 16.0;

  /// 24 px
  static const xLarge = 24.0;

  /// 32 px
  static const xxLarge = 32.0;

  /// 40 px
  static const largeX3 = 40.0;

  /// 48 px
  static const largeX4 = 48.0;

  /// 64 px
  static const largeX5 = 64.0;

  /// 80 px
  static const largeX6 = 80.0;
}

class VerticalSpacer extends StatelessWidget {
  const VerticalSpacer._(
    this._height, {
    Key? key,
  }) : super(key: key);

  /// 4 px
  const VerticalSpacer.xSmall({Key? key})
      : this._(
          Spacing.xSmall,
          key: key,
        );

  /// 8 px
  const VerticalSpacer.small({Key? key})
      : this._(
          Spacing.small,
          key: key,
        );

  /// 12 px
  const VerticalSpacer.medium({Key? key})
      : this._(
          Spacing.medium,
          key: key,
        );

  /// 16 px
  const VerticalSpacer.large({Key? key})
      : this._(
          Spacing.large,
          key: key,
        );

  /// 24 px
  const VerticalSpacer.xLarge({Key? key})
      : this._(
          Spacing.xLarge,
          key: key,
        );

  /// 32 px
  const VerticalSpacer.xxLarge({Key? key})
      : this._(
          Spacing.xxLarge,
          key: key,
        );

  /// 40 px
  const VerticalSpacer.largeX3({Key? key})
      : this._(
          Spacing.largeX3,
          key: key,
        );

  /// 48 px
  const VerticalSpacer.largeX4({Key? key})
      : this._(
          Spacing.largeX4,
          key: key,
        );

  /// 64 px
  const VerticalSpacer.largeX5({Key? key})
      : this._(
          Spacing.largeX5,
          key: key,
        );

  /// 80 px
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

  /// 4 px
  const HorizontalSpacer.xSmall({Key? key})
      : this._(
          Spacing.xSmall,
          key: key,
        );

  /// 8 px
  const HorizontalSpacer.small({Key? key})
      : this._(
          Spacing.small,
          key: key,
        );

  /// 12 px
  const HorizontalSpacer.medium({Key? key})
      : this._(
          Spacing.medium,
          key: key,
        );

  /// 16 px
  const HorizontalSpacer.large({Key? key})
      : this._(
          Spacing.large,
          key: key,
        );

  /// 24 px
  const HorizontalSpacer.xLarge({Key? key})
      : this._(
          Spacing.xLarge,
          key: key,
        );

  /// 32 px
  const HorizontalSpacer.xxLarge({Key? key})
      : this._(
          Spacing.xxLarge,
          key: key,
        );

  /// 40 px
  const HorizontalSpacer.largeX3({Key? key})
      : this._(
          Spacing.largeX3,
          key: key,
        );

  /// 48 px
  const HorizontalSpacer.largeX4({Key? key})
      : this._(
          Spacing.largeX4,
          key: key,
        );

  /// 64 px
  const HorizontalSpacer.largeX5({Key? key})
      : this._(
          Spacing.largeX5,
          key: key,
        );

  /// 80 px
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
