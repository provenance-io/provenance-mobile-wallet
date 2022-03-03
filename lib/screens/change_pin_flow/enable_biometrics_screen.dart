import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/change_pin_flow/change_pin_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class EnableBiometricsScreen extends StatelessWidget {
  EnableBiometricsScreen({
    Key? key,
  }) : super(key: key);

  final bloc = get<ChangePinBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.faceId,
        leadingIcon: PwIcons.back,
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
                        PwIcons.faceId,
                        color: Theme.of(context).colorScheme.neutralNeutral,
                      ),
                    ],
                  ),
                  VerticalSpacer.largeX4(),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwText(
                      Strings.useFaceIdTitle,
                      style: PwTextStyle.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VerticalSpacer.large(),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwText(
                      Strings.useYourFaceId,
                      style: PwTextStyle.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(child: Container()),
                  SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwButton(
                      child: PwText(
                        Strings.enable,
                        style: PwTextStyle.bodyBold,
                        color: PwColor.neutralNeutral,
                      ),
                      onPressed: () async {
                        get<ChangePinBloc>().enrollInBiometrics(context, true);
                      },
                    ),
                  ),
                  VerticalSpacer.large(),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwTextButton(
                      child: PwText(
                        Strings.skipForNow,
                        style: PwTextStyle.subhead,
                        color: PwColor.neutralNeutral,
                      ),
                      onPressed: () async {
                        get<ChangePinBloc>().enrollInBiometrics(context, false);
                      },
                    ),
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
}
