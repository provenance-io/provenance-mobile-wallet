import 'package:provenance_wallet/common/pw_design.dart';

class DetailsHeader extends StatelessWidget {
  final String title;

  const DetailsHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VerticalSpacer.largeX3(),
        Row(
          children: [
            PwText(
              title,
              style: PwTextStyle.subhead,
            )
          ],
        ),
        VerticalSpacer.large(),
      ],
    );
  }
}
