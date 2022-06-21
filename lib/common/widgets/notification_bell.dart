import 'dart:math';

import 'package:flutter_svg/svg.dart';
import 'package:provenance_wallet/common/pw_design.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell(
      {required this.notificationCount,
      Color? activeColor,
      Color? inactiveColor,
      int? placeCount,
      Duration? animationDuration,
      Key? key})
      : assert(notificationCount >= 0),
        assert(placeCount == null || placeCount > 0),
        activeColor = activeColor ?? Colors.white,
        inactiveColor = inactiveColor ?? Colors.grey,
        placeCount = placeCount ?? 3,
        animationDuration =
            animationDuration ?? const Duration(milliseconds: 75),
        super(key: key);

  final int notificationCount;
  final Color activeColor;
  final Color inactiveColor;
  final int placeCount;
  final Duration animationDuration;

  @override
  State<StatefulWidget> createState() => NotificationBellState();
}

class NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  final _matrix = Matrix4.translationValues(2.0, -2.0, 0.0)..rotateZ(pi / 8);
  late AnimationController _shakeController;
  int runCount = 0;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        reverseDuration: widget.animationDuration);

    _shakeController.addStatusListener(_shakeControllerListener);
  }

  @override
  void didUpdateWidget(covariant NotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.notificationCount != widget.notificationCount) {
      _restartAnimation();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationCount = widget.notificationCount;

    final bellColor =
        (notificationCount > 0) ? widget.activeColor : widget.inactiveColor;

    final badgeString = _formatNotificationCount(notificationCount);

    return AspectRatio(
      aspectRatio: 1,
      child: IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          onPressed: () {
            _restartAnimation();
          },
          icon: LayoutBuilder(
            builder: (context, constraints) {
              final dimen = max(constraints.maxHeight * (2 / 5), 24.0);

              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      child: Transform(
                        origin: Offset(dimen / 2, dimen / 2),
                        transform: _matrix,
                        child: SvgPicture.asset(
                          'assets/bell.svg',
                          fit: BoxFit.contain,
                          width: double.maxFinite,
                          height: double.maxFinite,
                          color: bellColor,
                        ),
                      ),
                      builder: (context, child) {
                        final v = sin((pi / 4) * _shakeController.value);
                        return Transform.rotate(
                          child: child,
                          angle: v,
                        );
                      },
                    ),
                  ),
                  if (badgeString?.isNotEmpty ?? false)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: dimen,
                        width: dimen,
                        padding: const EdgeInsets.all(2.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: FittedBox(
                          child: Text(
                            badgeString!,
                            style:
                                TextStyle(backgroundColor: Colors.transparent),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                ],
              );
            },
          )),
    );
  }

  void _restartAnimation() {
    _shakeController.reset();
    _shakeController.forward();
  }

  void _shakeControllerListener(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      runCount += 1;
      if (runCount < 3) {
        _shakeController.forward();
      } else {
        runCount = 0;
      }
    } else if (status == AnimationStatus.completed) {
      _shakeController.reverse();
    }
  }

  String? _formatNotificationCount(int count) {
    final totalPlaces = pow(10, widget.placeCount);

    if (count <= 0) {
      return null;
    } else if (count > totalPlaces) {
      return "$totalPlaces+";
    } else {
      return "$count";
    }
  }
}
