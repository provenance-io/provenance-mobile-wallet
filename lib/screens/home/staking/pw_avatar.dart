import 'package:provenance_wallet/common/pw_design.dart';

class PwAvatar extends StatelessWidget {
  final String initial;
  final String imgUrl;

  const PwAvatar({
    Key? key,
    required this.initial,
    required this.imgUrl,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Spacing.largeX3,
      height: Spacing.largeX3,
      child: Container(
        decoration: ShapeDecoration(
          shape: CircleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.neutralNeutral,
            ),
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.neutralNeutral,
          foregroundImage: NetworkImage(imgUrl),
          child: PwText(
            initial.toUpperCase(),
          ),
        ),
      ),
    );
  }
}
