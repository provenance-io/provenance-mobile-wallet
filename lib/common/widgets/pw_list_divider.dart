import '../pw_design.dart';

class PwListDivider extends StatelessWidget {
  const PwListDivider({Key? key, this.indent}) : super(key: key);

  final double? indent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: indent,
      color: Theme.of(context).colorScheme.provenanceNeutral600,
    );
  }
}
