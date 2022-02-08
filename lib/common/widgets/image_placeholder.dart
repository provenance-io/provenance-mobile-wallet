import 'package:provenance_wallet/common/pw_design.dart';

class ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 158,
      width: 158,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.globalNeutral350,
        borderRadius: BorderRadius.all(Radius.circular(79)),
      ),
    );
  }
}
