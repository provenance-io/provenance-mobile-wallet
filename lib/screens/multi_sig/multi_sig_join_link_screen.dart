import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigJoinLinkScreen extends StatefulWidget {
  const MultiSigJoinLinkScreen({Key? key}) : super(key: key);

  @override
  State<MultiSigJoinLinkScreen> createState() => _MultiSigJoinLinkScreenState();
}

class _MultiSigJoinLinkScreenState extends State<MultiSigJoinLinkScreen> {
  final _textController = TextEditingController();
  var _valid = false;
  final _formKey = GlobalKey(
    debugLabel: '$MultiSigJoinLinkScreen',
  );

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      final valid = _validate(_textController.text) == null;
      if (valid != _valid) {
        setState(() {
          _valid = valid;
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
        title: Strings.multiSigJoinLinkTitle,
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
                    horizontal: Spacing.xxLarge,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        PwText(
                          Strings.multiSigJoinLinkMessage,
                          style: PwTextStyle.body,
                          color: PwColor.neutralNeutral,
                          textAlign: TextAlign.center,
                        ),
                        VerticalSpacer.largeX4(),
                        PwTextFormField(
                          label: Strings.multiSigJoinLinkFieldLabel,
                          validator: _validate,
                          controller: _textController,
                          autofocus: true,
                          autovalidateMode: AutovalidateMode.disabled,
                          onFieldSubmitted: _submit,
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
                      Strings.continueName,
                      style: PwTextStyle.bodyBold,
                      color: PwColor.neutralNeutral,
                    ),
                    onPressed: () => _submit(_textController.text),
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

  void _submit(String text) {
    if ((_formKey.currentState as FormState?)?.validate() == true) {
      get<AddAccountFlowBloc>().submitMultiSigJoinLink(_textController.text);
    }
  }

  String? _validate(String? text) {
    String? error;

    if (text == null || text.isEmpty) {
      error = Strings.required;
    } else {
      final valid = text.startsWith('https://provenance.io/');
      if (!valid) {
        error = Strings.multiSigInvalidLink;
      }
    }

    return error;
  }
}
