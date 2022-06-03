import 'package:provenance_wallet/common/pw_design.dart';

class WarningSection extends StatelessWidget {
  final String _title;
  final String _message;
  final Color? _background;
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
        _background = background,
        _textColor = textColor,
        _pwIconName = pwIconName,
        _iconColor = iconColor,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: Spacing.large,
        bottom: Spacing.large,
      ),
      padding: EdgeInsets.symmetric(
        vertical: Spacing.large,
        horizontal: Spacing.xxLarge,
      ),
      color: _background ?? Theme.of(context).colorScheme.notice350,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(
              right: Spacing.large,
            ),
            child: PwIcon(
              _pwIconName ?? PwIcons.warn,
              color: _iconColor ?? Theme.of(context).colorScheme.neutral800,
              size: 24,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PwText(
                      _title,
                      style: PwTextStyle.subhead,
                      color: _textColor ?? PwColor.notice800,
                      textAlign: TextAlign.left,
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
                    style: PwTextStyle.body,
                    color: _textColor ?? PwColor.notice800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
