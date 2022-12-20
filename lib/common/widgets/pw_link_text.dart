import 'package:flutter/gestures.dart';
import 'package:provenance_wallet/common/pw_design.dart';

///
/// Converts markdown formatted links within [text] into clickable links.
/// E.g. 'Here is a link to [Provenance](https://provenance.io).'
///
class PwLinkText extends StatefulWidget {
  const PwLinkText({
    required this.text,
    required this.onTap,
    this.textStyle,
    this.linkStyle,
    Key? key,
  }) : super(key: key);

  final String text;
  final void Function(String uri) onTap;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;

  @override
  State<PwLinkText> createState() => _PwLinkTextState();

  @visibleForTesting
  static List<InlineSpan> parse({
    required String markdown,
    TextStyle? textStyle,
    TextStyle? linkStyle,
    TapGestureRecognizer Function(String uri)? createRecognizer,
  }) {
    final reg = RegExp(r'\[(.*?)\]\((.*?)\)');

    final matches = reg.allMatches(markdown).toList();
    final spans = <InlineSpan>[];

    if (matches.isNotEmpty) {
      if (matches.first.start != 0) {
        spans.add(
          TextSpan(
            text: markdown.substring(0, matches.first.start),
            style: textStyle,
          ),
        );
      }

      for (var i = 0; i < matches.length; i++) {
        final match = matches[i];
        final linkText = match.group(1)!;
        final uri = match.group(2)!;

        spans.add(
          TextSpan(
            text: linkText,
            recognizer: createRecognizer?.call(uri),
            style: linkStyle,
          ),
        );

        if (i < matches.length - 1) {
          final nextMatch = matches[i + 1];
          if (nextMatch.start > match.end) {
            spans.add(
              TextSpan(
                text: markdown.substring(match.end, nextMatch.start),
                style: textStyle,
              ),
            );
          }
        }
      }

      if (matches.last.end <= markdown.length - 1) {
        spans.add(
          TextSpan(
            text: markdown.substring(matches.last.end),
            style: textStyle,
          ),
        );
      }
    } else {
      spans.add(
        TextSpan(
          text: markdown,
          style: textStyle,
        ),
      );
    }

    return spans;
  }
}

class _PwLinkTextState extends State<PwLinkText> {
  final _recognizers = <GestureRecognizer>[];
  List<InlineSpan>? _spans;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _spans ??= PwLinkText.parse(
      markdown: widget.text,
      textStyle: widget.textStyle,
      linkStyle: widget.linkStyle ??
          TextStyle(
            color: Theme.of(context).colorScheme.primary500,
            decoration: TextDecoration.underline,
          ),
      createRecognizer: (String uri) {
        final recognizer = TapGestureRecognizer();
        recognizer.onTap = () => widget.onTap(uri);
        _recognizers.add(recognizer);

        return recognizer;
      },
    );
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          children: _spans,
        ),
      );
}
