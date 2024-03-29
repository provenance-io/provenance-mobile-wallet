import 'package:provenance_wallet/common/pw_design.dart';

class PwOnboardingScreen extends StatelessWidget {
  const PwOnboardingScreen({
    required this.children,
    Key? key,
  }) : super(key: key);

  static final keyScrollView = ValueKey('$PwOnboardingScreen.scroll_view');

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Theme.of(context).colorScheme.neutral750,
          child: SingleChildScrollView(
            key: keyScrollView,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
