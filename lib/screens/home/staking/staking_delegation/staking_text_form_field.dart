import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingTextFormField extends StatelessWidget {
  final String hint;
  final TextEditingController textEditingController;
  final Function? submit;
  final ScrollController? scrollController;
  final bool shouldAutovalidate;
  final TextInputType keyboardType;

  const StakingTextFormField({
    Key? key,
    required this.hint,
    required this.textEditingController,
    this.shouldAutovalidate = true,
    this.submit,
    this.scrollController,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      style: theme.textTheme.body,
      keyboardType: keyboardType,
      autocorrect: false,
      controller: textEditingController,
      onFieldSubmitted: (_) {
        if (submit != null) {
          submit!();
        }
      },
      onTap: () async {
        if (scrollController == null) {
          return;
        }
        await Future.delayed(
          Duration(
            milliseconds: 575,
          ),
        );

        await scrollController!.animateTo(
          scrollController!.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.decelerate,
        );
      },
      autovalidateMode: shouldAutovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return Strings.of(context).starRequired;
        }
        final number = num.tryParse(value);
        return keyboardType == TextInputType.numberWithOptions(decimal: true) &&
                    null == number ||
                number?.isNegative == true
            ? Strings.of(context).starPositiveNumber
            : null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            theme.textTheme.body.copyWith(color: theme.colorScheme.neutral250),
        fillColor: theme.colorScheme.neutral750,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.primary500,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: _enabledBorder(
          theme.colorScheme.neutral250,
        ),
        errorStyle: theme.textTheme.footnote.copyWith(
          color: theme.colorScheme.neutral150,
        ),
        focusedErrorBorder: _enabledBorder(
          theme.colorScheme.neutral250,
        ),
        errorBorder: _enabledBorder(
          theme.colorScheme.neutral250,
        ),
      ),
    );
  }

  InputBorder _enabledBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
      ),
    );
  }
}
