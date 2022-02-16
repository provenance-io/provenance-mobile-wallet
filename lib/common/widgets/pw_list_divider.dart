import '../pw_design.dart';

class PwListDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.provenanceNeutral600,
    );
  }
}
