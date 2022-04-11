import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:provenance_wallet/common/pw_design.dart';

/// *
/// This control standardizes how the onboarding screens look/behave. The
/// content will be scrollable with a standard horizontal padding.  If the
/// content is smaller than the scrollable area it will scroll only to the bottom
/// of the content. If the content is larger than the scrollable area then the content
/// will be vertically centered, offset by up to the bottomOffset value.
class PwOnboardingView extends StatefulWidget {
  const PwOnboardingView({
    required this.children,
    this.bottomOffset = Spacing.largeX6 + Spacing.largeX5,
    Key? key,
  }) : super(key: key);

  final List<Widget> children;
  final double bottomOffset;

  @override
  State<StatefulWidget> createState() => _PwOnboardingViewState();
}

class _PwOnboardingViewState extends State<PwOnboardingView> {
  final _columnKey = GlobalKey();
  final _scrollKey = GlobalKey();
  final ValueNotifier<double> _paddingSize = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      final columnSize = _columnKey.currentContext!.size;
      final scrollSize = _scrollKey.currentContext!.size;

      final diff = scrollSize!.height - columnSize!.height;
      if (diff > 0) {
        _paddingSize.value = min(widget.bottomOffset, diff);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        key: _scrollKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            key: _columnKey,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...widget.children,
              ValueListenableBuilder<double>(
                valueListenable: _paddingSize,
                builder: (
                  context,
                  value,
                  _,
                ) {
                  return VerticalSpacer.custom(spacing: value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
