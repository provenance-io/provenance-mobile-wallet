import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/change_pin_flow/change_pin_bloc.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ChangedPinSuccessFullyScreen extends StatelessWidget {
  const ChangedPinSuccessFullyScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        hasIcon: false,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: viewportConstraints,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    VerticalSpacer.largeX6(),
                    VerticalSpacer.xxLarge(),
                    PwText(
                      Strings.of(context).successName.toUpperCase(),
                      style: PwTextStyle.headline2,
                      textAlign: TextAlign.center,
                    ),
                    VerticalSpacer.large(),
                    Padding(
                      padding: EdgeInsets.only(
                        right: Spacing.xxLarge,
                        left: Spacing.xxLarge,
                      ),
                      child: PwText(
                        Strings.of(context).pinCodeUpdated,
                        style: PwTextStyle.body,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    VerticalSpacer.large(),
                    VerticalSpacer.medium(),
                    Image.asset(
                      Assets.imagePaths.createPassphrase,
                      width: 180,
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: PwButton(
                        child: PwText(
                          Strings.of(context).continueName,
                          style: PwTextStyle.subhead,
                          color: PwColor.neutralNeutral,
                        ),
                        onPressed: () async {
                          get<ChangePinBloc>().returnToProfile();
                        },
                      ),
                    ),
                    VerticalSpacer.xxLarge(),
                    VerticalSpacer.xxLarge(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
