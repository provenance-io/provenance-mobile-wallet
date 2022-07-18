import 'package:provenance_wallet/common/pw_design.dart';

class WarningSection extends StatelessWidget {
  final String _title;
  final String _message;
  final PwColor? _textColor;
  final String? _pwIconName;
  final Color? _iconColor;

  const WarningSection({
    Key? key,
    required String title,
    required String message,
    Color? background,
    PwColor? textColor,
    String? pwIconName,
    Color? iconColor,
  })  : _title = title,
        _message = message,
        _textColor = textColor,
        _pwIconName = pwIconName,
        _iconColor = iconColor,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary500,
        ),
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.primary500,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              Spacing.large,
            ),
            child: PwIcon(
              _pwIconName ?? PwIcons.warnCircle,
              color: _iconColor ?? Theme.of(context).colorScheme.neutral600,
              size: 24,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(Spacing.large),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.neutral750,
                ),
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.neutral750,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: PwText(
                          _title,
                          style: PwTextStyle.body,
                          color: _textColor ?? PwColor.neutralNeutral,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.fade,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: Spacing.xSmall,
                    ),
                    child: PwText(
                      _message,
                      textAlign: TextAlign.left,
                      style: PwTextStyle.footnote,
                      color: _textColor ?? PwColor.neutral250,
                      overflow: TextOverflow.fade,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
