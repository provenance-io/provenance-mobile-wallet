import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingTextFormField extends StatelessWidget {
  final String hint;
  final TextEditingController textEditingController;
  final Function? submit;

  const StakingTextFormField({
    Key? key,
    required this.hint,
    required this.textEditingController,
    this.submit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      style: theme.textTheme.body,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      autocorrect: false,
      controller: textEditingController,
      onFieldSubmitted: (_) {
        if (submit != null) {
          submit!();
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return Strings.required;
        }
        final number = num.tryParse(value);
        return null == number || number.isNegative ? "*positive number" : null;
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
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.neutral250,
          ),
        ),
      ),
    );
  }
}
