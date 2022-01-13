import 'package:flutter/material.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';

extension Spacing on double {
  static const xSmall = 4.0;
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xLarge = 32.0;
  static const xxLarge = 40.0;
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

  final double? _width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _width);
  }
}
