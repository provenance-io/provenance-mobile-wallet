import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_theme.dart';

class ContainerCircleButton extends StatefulWidget {
  const ContainerCircleButton({
    Key? key,
    required this.child,
    required this.onClick,
  }) : super(key: key);

  final Widget child;
  final Function onClick;

  @override
  State<StatefulWidget> createState() => _ContainerCircleButtonState();
}

class _ContainerCircleButtonState extends State<ContainerCircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration.zero,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapCancel: () {
        setState(() {
          _controller.value = 0;
        });
      },
      onTapDown: (details) {
        setState(() {
          _controller.value = 1;
        });
        widget.onClick();
      },
      onTapUp: (details) {
        setState(() {
          _controller.value = 0;
        });
      },
      child: Container(
        height: 92,
        width: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary700
                  .withOpacity(_controller.value),
              spreadRadius: 20,
            ),
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary650
                  .withOpacity(_controller.value),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: widget.child,
        ),
      ),
    );
  }
}
