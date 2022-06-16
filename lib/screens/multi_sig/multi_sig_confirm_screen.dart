import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_name_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_count_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_field.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigConfirmScreen extends StatelessWidget {
  const MultiSigConfirmScreen({
    required this.currentStep,
    required this.totalSteps,
    required AddAccountFlowBloc bloc,
    Key? key,
  })  : _bloc = bloc,
        super(key: key);

  final int currentStep;
  final int totalSteps;

  final AddAccountFlowBloc _bloc;

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

                        return MultiSigField(
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
                                    bloc: _bloc,
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

                        return MultiSigField(
                          name: Strings.multiSigConfirmCosignersLabel,
                          value: count.toString(),
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) {
                                  return MultiSigCountScreen.cosigners(
                                    bloc: _bloc,
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

                        return MultiSigField(
                          name: Strings.multiSigConfirmSignaturesLabel,
                          value: count.toString(),
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) {
                                  return MultiSigCountScreen.signatures(
                                    bloc: _bloc,
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
