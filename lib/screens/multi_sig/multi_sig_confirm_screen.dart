import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_name_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_count_screen.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigConfirmScreen extends StatelessWidget {
  MultiSigConfirmScreen({
    required this.currentStep,
    required this.totalSteps,
    Key? key,
  }) : super(key: key);

  final int currentStep;
  final int totalSteps;

  final _bloc = get<AddAccountFlowBloc>();

  @override
  Widget build(BuildContext context) {
    const divider = Divider(
      thickness: 1,
    );

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.multiSigConfirmTitle,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          currentStep,
          totalSteps,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Spacing.xxLarge,
              ),
              child: Column(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerticalSpacer.largeX3(),
                  PwText(
                    Strings.multiSigConfirmMessage,
                    style: PwTextStyle.body,
                    color: PwColor.neutralNeutral,
                  ),
                  VerticalSpacer.largeX4(),
                  StreamBuilder<String>(
                      initialData: _bloc.multiSigName.valueOrNull,
                      stream: _bloc.multiSigName,
                      builder: (context, snapshot) {
                        final name = snapshot.data ?? '';

                        return _Field(
                          name: Strings.multiSigConfirmAccountNameLabel,
                          value: name,
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) {
                                  return AccountNameScreen.multi(
                                    mode: FieldMode.edit,
                                    leadingIcon: PwIcons.close,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }),
                  divider,
                  StreamBuilder<Count>(
                      initialData: _bloc.multiSigCosignerCount.valueOrNull,
                      stream: _bloc.multiSigCosignerCount,
                      builder: (context, snapshot) {
                        final count = snapshot.data?.value ?? 0;

                        return _Field(
                          name: Strings.multiSigConfirmCosignersLabel,
                          value: count.toString(),
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) {
                                  return MultiSigCountScreen.cosigners(
                                    mode: FieldMode.edit,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }),
                  divider,
                  StreamBuilder<Count>(
                      initialData: _bloc.multiSigSignatureCount.valueOrNull,
                      stream: _bloc.multiSigSignatureCount,
                      builder: (context, snapshot) {
                        final count = snapshot.data?.value ?? 0;

                        return _Field(
                          name: Strings.multiSigConfirmSignaturesLabel,
                          value: count.toString(),
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) {
                                  return MultiSigCountScreen.signatures(
                                    mode: FieldMode.edit,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }),
                  Expanded(
                    child: SizedBox(),
                  ),
                  VerticalSpacer.large(),
                  PwButton(
                    autofocus: true,
                    child: PwText(
                      Strings.multiSigNextButton,
                      style: PwTextStyle.bodyBold,
                      color: PwColor.neutralNeutral,
                    ),
                    onPressed: () => _bloc.submitMultiSigConfirm(context),
                  ),
                  VerticalSpacer.largeX4(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.name,
    required this.value,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  final String name;
  final String value;
  final void Function() onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: Spacing.small,
        left: Spacing.small,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                top: Spacing.small,
              ),
              child: Column(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwText(
                    name,
                    style: PwTextStyle.bodyBold,
                    overflow: TextOverflow.fade,
                  ),
                  PwText(
                    value,
                    style: PwTextStyle.body,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: PwIcon(
              PwIcons.edit,
              color: Theme.of(context).colorScheme.neutralNeutral,
            ),
          ),
        ],
      ),
    );
  }
}
