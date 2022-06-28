import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/strings.dart';

class EnableFaceIdScreen extends StatelessWidget {
  const EnableFaceIdScreen({
    required this.bloc,
    required this.currentStep,
    required this.totalSteps,
    Key? key,
  }) : super(key: key);

  final AddAccountFlowBloc bloc;
  final int currentStep;
  final int totalSteps;

  static final keyEnableButton = ValueKey('$EnableFaceIdScreen.enable_button');
  static final keySkipButton = ValueKey('$EnableFaceIdScreen.skip_button');

  @override
  Widget build(BuildContext context) {
    String header;
    String title;
    String message;
    String icon;

    switch (bloc.biometryType) {
      case BiometryType.faceId:
        header = Strings.faceId;
        title = Strings.useFaceIdTitle;
        message = Strings.useYourFaceId;
        icon = PwIcons.faceId;
        break;
      case BiometryType.touchId:
        header = Strings.touchId;
        title = Strings.useTouchIdTitle;
        message = Strings.useYourFingerPrint;
        icon = PwIcons.touchId;
        break;
      case BiometryType.unknown:
      case BiometryType.none:
        header = Strings.useBiometryTitle;
        title = Strings.useBiometryTitle;
        message = Strings.useBiometryMessage;
        icon = PwIcons.faceId;
        break;
    }

    Widget skipButton;
    skipButton = bloc.biometryType == BiometryType.none
        ? PwTextButton.primaryAction(
            key: keySkipButton,
            context: context,
            onPressed: () async {
              _submit(context, useBiometry: false);
            },
            text: Strings.skipForNow,
          )
        : PwTextButton(
            key: keySkipButton,
            child: PwText(
              Strings.skipForNow,
              style: PwTextStyle.subhead,
              color: PwColor.neutralNeutral,
            ),
            onPressed: () async {
              _submit(
                context,
                useBiometry: false,
              );
            },
          );

    return Scaffold(
      appBar: PwAppBar(
        title: header,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          currentStep,
          totalSteps,
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: viewportConstraints,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VerticalSpacer.custom(
                    spacing: 104,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PwIcon(
                        icon,
                        color: Theme.of(context).colorScheme.neutralNeutral,
                      ),
                    ],
                  ),
                  VerticalSpacer.largeX4(),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwText(
                      title,
                      style: PwTextStyle.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VerticalSpacer.large(),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwText(
                      message,
                      style: PwTextStyle.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(child: Container()),
                  SizedBox(
                    height: 24,
                  ),
                  if (bloc.biometryType != BiometryType.none)
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: PwButton(
                        key: keyEnableButton,
                        autofocus: true,
                        child: PwText(
                          Strings.enable,
                          style: PwTextStyle.bodyBold,
                          color: PwColor.neutralNeutral,
                        ),
                        onPressed: () async {
                          _submit(
                            context,
                            useBiometry: true,
                          );
                        },
                      ),
                    ),
                  VerticalSpacer.large(),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: skipButton,
                  ),
                  VerticalSpacer.largeX4(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context, {
    required bool useBiometry,
  }) async {
    await bloc.submitEnableFaceId(
      context: context,
      useBiometry: useBiometry,
    );
  }
}
