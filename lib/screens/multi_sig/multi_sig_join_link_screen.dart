import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/account/multi_sig_join_link_flow.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/invite_link_util.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class MultiSigJoinLinkBloc {
  MultiSigJoinLinkBloc({
    required MultiSigJoinLinkFlowNavigator navigator,
  }) : _navigator = navigator;
  final MultiSigJoinLinkFlowNavigator _navigator;
  final _client = get<MultiSigClient>();
  final _multiSigInviteLinkError = PublishSubject<String?>();

  Stream<String?> get multiSigInviteLinkError => _multiSigInviteLinkError;

  Future<bool> submitMultiSigJoinLink(
    String multiSigInvalidLink,
    String link,
  ) async {
    var success = false;

    final redirectedLink = await tryFollowRedirect(link);
    if (redirectedLink != null) {
      final linkData = parseInviteLinkData(redirectedLink);
      if (linkData != null) {
        final remoteAccount = await _client.getAccountByInvite(
          inviteId: linkData.inviteId,
          coin: linkData.coin,
        );
        if (remoteAccount != null) {
          success = true;

          _navigator.showInviteReviewFlow(
            inviteId: linkData.inviteId,
            remoteAccount: remoteAccount,
          );
        }
      }
    }

    if (!success) {
      _multiSigInviteLinkError.tryAdd(
        multiSigInvalidLink,
      );
    }

    return success;
  }
}

class MultiSigJoinLinkScreen extends StatefulWidget {
  const MultiSigJoinLinkScreen({
    required MultiSigJoinLinkBloc bloc,
    Key? key,
  })  : _bloc = bloc,
        super(key: key);

  final MultiSigJoinLinkBloc _bloc;

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

  void _onLoading(BuildContext context, bool loading) {
    if (loading) {
      ModalLoadingRoute.showLoading(context);
    } else {
      ModalLoadingRoute.dismiss(context);
    }
  }

  Future<void> _submit(BuildContext context, String text) async {
    if ((_formKey.currentState as FormState?)?.validate() == true) {
      _onLoading(context, true);
      final success = await widget._bloc.submitMultiSigJoinLink(
        Strings.of(context).multiSigInvalidLink,
        _textController.text.trim(),
      );
      _onLoading(context, false);
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
      final valid = parseInviteLinkData(text) != null;
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
