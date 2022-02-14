import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_theme.dart';

class DeleteButton extends StatefulWidget {
  const DeleteButton({
    Key? key,
    required this.deleteNumber,
  }) : super(key: key);

  final Function deleteNumber;

  @override
  State<StatefulWidget> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        microseconds: 5,
      ),
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
      onTapDown: (details) {
        setState(() {
          _controller.value = 1;
        });
        widget.deleteNumber();
      },
      onTapUp: (details) {
        setState(() {
          _controller.value = 0;
        });
      },
      child: Container(
        height: 50,
        width: 50,
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
          child: PwIcon(
            PwIcons.remove,
            size: 22,
            color: Theme.of(context).colorScheme.white,
          ),
        ),
      ),
    );
  }
}
