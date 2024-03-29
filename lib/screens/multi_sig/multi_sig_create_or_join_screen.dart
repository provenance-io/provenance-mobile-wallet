import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_button.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_add_kind.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class MultiSigCreateOrJoinBloc {
  void submitMultiSigCreateOrJoin(MultiSigAddKind kind);
}

class MultiSigCreateOrJoinScreen extends StatelessWidget {
  const MultiSigCreateOrJoinScreen({
    required MultiSigCreateOrJoinBloc bloc,
    required Set<MultiSigAddKind> addKinds,
    Key? key,
  })  : _bloc = bloc,
        _addKinds = addKinds,
        super(key: key);

  static final keyJoinMultiSig =
      ValueKey('$MultiSigCreateOrJoinScreen.join_button');

  final Set<MultiSigAddKind> _addKinds;
  final MultiSigCreateOrJoinBloc _bloc;

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PwAppBar(
        title: strings.accountTypeMultiSigTitle,
        leadingIcon: PwIcons.back,
      ),
      backgroundColor: Theme.of(context).colorScheme.neutral750,
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.large,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VerticalSpacer.largeX3(),
                    PwText(
                      strings.accountTypeMultiSigDesc,
                      style: PwTextStyle.body,
                      color: PwColor.neutralNeutral,
                    ),
                    VerticalSpacer.largeX3(),
                    if (_addKinds.contains(MultiSigAddKind.create))
                      AccountButton(
                        name: strings.accountTypeMultiSigCreateName,
                        desc: strings.accountTypeMultiSigCreateDesc,
                        onPressed: () => _bloc.submitMultiSigCreateOrJoin(
                          MultiSigAddKind.create,
                        ),
                      ),
                    if (_addKinds.contains(MultiSigAddKind.recover))
                      VerticalSpacer.large(),
                    if (_addKinds.contains(MultiSigAddKind.recover))
                      AccountButton(
                        name: strings.accountTypeMultiSigRecoverName,
                        desc: strings.accountTypeMultiSigRecoverDesc,
                        onPressed: () => _bloc.submitMultiSigCreateOrJoin(
                          MultiSigAddKind.recover,
                        ),
                      ),
                    if (_addKinds.contains(MultiSigAddKind.join))
                      VerticalSpacer.large(),
                    if (_addKinds.contains(MultiSigAddKind.join))
                      AccountButton(
                        name: strings.accountTypeMultiSigJoinName,
                        desc: strings.accountTypeMultiSigJoinDesc,
                        onPressed: () => _bloc.submitMultiSigCreateOrJoin(
                          MultiSigAddKind.join,
                        ),
                      ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    if (_addKinds.contains(MultiSigAddKind.link))
                      TextButton(
                        onPressed: () => _bloc.submitMultiSigCreateOrJoin(
                          MultiSigAddKind.link,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(
                            Spacing.medium,
                          ),
                          child: PwText(
                            strings.accountTypeMultiSigJoinLink,
                            style: PwTextStyle.body,
                            textAlign: TextAlign.center,
                            underline: true,
                          ),
                        ),
                      ),
                    VerticalSpacer.largeX4(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
