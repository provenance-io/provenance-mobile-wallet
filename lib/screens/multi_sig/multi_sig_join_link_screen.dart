import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigJoinLinkScreen extends StatefulWidget {
  const MultiSigJoinLinkScreen({
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  final Future<bool> Function(
    BuildContext context,
    String link,
  ) onSubmit;

  @override
  State<MultiSigJoinLinkScreen> createState() => _MultiSigJoinLinkScreenState();
}

class _MultiSigJoinLinkScreenState extends State<MultiSigJoinLinkScreen> {
  final _textController = TextEditingController();
  var _valid = false;
  final _formKey = GlobalKey(
    debugLabel: '$MultiSigJoinLinkScreen',
  );

  late String? Function(String? text) _validate;
  var _mode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();

    _validate = _validateTyping;

    _textController.addListener(() {
      final valid = _validateComplete(_textController.text) == null;
      final validate = _validateTyping;
      if (valid != _valid || _validate != validate) {
        setState(() {
          _valid = valid;
          _validate = validate;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        leadingIcon: PwIcons.back,
        title: Strings.of(context).multiSigJoinLinkTitle,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        PwText(
                          Strings.of(context).multiSigJoinLinkMessage,
                          style: PwTextStyle.body,
                          color: PwColor.neutralNeutral,
                          textAlign: TextAlign.center,
                        ),
                        VerticalSpacer.largeX4(),
                        PwTextFormField(
                          label: Strings.of(context).multiSigJoinLinkFieldLabel,
                          validator: _validate,
                          controller: _textController,
                          autofocus: true,
                          autovalidateMode: _mode,
                          onFieldSubmitted: (e) {
                            _submit(context, e);
                          },
                        ),
                        VerticalSpacer.large(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SizedBox(),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: PwButton(
                    enabled: _valid,
                    child: PwText(
                      Strings.of(context).continueName,
                      style: PwTextStyle.bodyBold,
                      color: PwColor.neutralNeutral,
                    ),
                    onPressed: () => _submit(context, _textController.text),
                  ),
                ),
                VerticalSpacer.largeX4(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, String text) async {
    if ((_formKey.currentState as FormState?)?.validate() == true) {
      final success = await widget.onSubmit(
        context,
        _textController.text.trim(),
      );

      if (!success) {
        setState(() {
          _validate = _validateInvalid;
          _mode = AutovalidateMode.always;
        });
      }
    }
  }

  String? _validateTyping(String? text) {
    String? error;

    if (text == null || text.isEmpty) {
      error = Strings.of(context).required;
    }

    return error;
  }

  String? _validateComplete(String? text) {
    String? error;

    if (text == null || text.isEmpty) {
      error = Strings.of(context).required;
    } else {
      const validHosts = {
        'provenancewallet.page.link',
        'provenance.io',
      };

      final uri = Uri.tryParse(text);
      final valid = uri != null &&
          uri.scheme == 'https' &&
          validHosts.contains(uri.host) &&
          uri.path.isNotEmpty &&
          uri.path != '/';
      if (!valid) {
        error = Strings.of(context).multiSigInvalidLink;
      }
    }

    return error;
  }

  String? _validateInvalid(String? text) {
    return Strings.of(context).multiSigInvalidLink;
  }
}
