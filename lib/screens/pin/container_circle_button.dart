import 'package:provenance_wallet/common/pw_design.dart';

class ContainerCircleButton extends StatelessWidget {
  const ContainerCircleButton({
    Key? key,
    required this.child,
    required this.onClick,
  }) : super(key: key);

  final Widget child;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary650;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.elasticIn,
      child: Material(
        child: InkResponse(
          highlightColor: color,
          splashColor: color,
          child: Center(
            child: child,
          ),
          onTap: () {
            onClick();
          },
        ),
      ),
    );
  }
}
