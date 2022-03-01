import 'package:provenance_wallet/common/pw_design.dart';

// TODO: Figure out how to apply colors on focus to match the design.
class PwTextFormField extends StatelessWidget {
  const PwTextFormField({
    Key? key,
    required this.label,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.controller,
    this.autofocus = false,
  }) : super(key: key);

  final String label;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PwText(
          label,
          color: PwColor.neutralNeutral,
        ),
        VerticalSpacer.small(),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.neutral550,
                spreadRadius: 6,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: TextFormField(
            autofocus: autofocus,
            style: theme.textTheme.body
                .copyWith(color: theme.colorScheme.neutralNeutral),
            keyboardType: keyboardType,
            autocorrect: false,
            controller: controller,
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: theme.textTheme.body
                  .copyWith(color: theme.colorScheme.neutral250),
              fillColor: theme.colorScheme.neutral750,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.neutral250,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}