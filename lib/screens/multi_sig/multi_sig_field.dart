import 'package:provenance_wallet/common/pw_design.dart';

class MultiSigField extends StatelessWidget {
  const MultiSigField({
    required this.name,
    required this.value,
    this.onEdit,
    Key? key,
  }) : super(key: key);

  final String name;
  final String value;
  final void Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: Spacing.small,
        left: Spacing.small,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                top: Spacing.small,
              ),
              child: Column(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwText(
                    name,
                    style: PwTextStyle.bodyBold,
                    overflow: TextOverflow.fade,
                  ),
                  PwText(
                    value,
                    style: PwTextStyle.body,
                  ),
                ],
              ),
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: PwIcon(
                PwIcons.edit,
                color: Theme.of(context).colorScheme.neutralNeutral,
              ),
            ),
        ],
      ),
    );
  }
}
