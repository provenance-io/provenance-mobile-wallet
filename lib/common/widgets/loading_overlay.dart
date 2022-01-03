import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Loading Overlay inspired by https://pub.dev/packages/loading_overlay
///
/// wrapper around any widget that makes an async call to show a modal progress
/// indicator while the async call is in progress.
///
/// The progress indicator can be turned on or off using [isLoading]
///
/// The progress indicator defaults to a [CircularProgressIndicator] but can be
/// any kind of widget
///
/// The color of the modal barrier can be set using [color]
///
/// The opacity of the modal barrier can be set using [opacity]
///
class LoadingOverlay extends HookWidget {
  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.opacity = 0.7,
    this.color,
    this.progressIndicator = const CircularProgressIndicator(),
  }) : super(key: key);

  final bool isLoading;
  final Widget child;
  final double opacity;
  final Color? color;
  final Widget progressIndicator;

  @override
  Widget build(BuildContext context) {
    final isVisible = useState(false);
    final _controller =
        useAnimationController(duration: const Duration(milliseconds: 300))
          ..addStatusListener((status) {
            if (!isVisible.value) {
              if (status == AnimationStatus.forward ||
                  status == AnimationStatus.reverse) {
                isVisible.value = true;
              }
            } else {
              if (status == AnimationStatus.dismissed) {
                isVisible.value = false;
              }
            }
          });

    if (isLoading) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return Stack(
      children: [
        child,
        if (isVisible.value)
          FadeTransition(
            opacity: _controller,
            child: Stack(
              children: <Widget>[
                Opacity(
                  child: ModalBarrier(
                    dismissible: false,
                    color: color ?? Theme.of(context).colorScheme.background,
                  ),
                  opacity: opacity,
                ),
                Center(child: progressIndicator),
              ],
            ),
          )
      ],
    );
  }
}
