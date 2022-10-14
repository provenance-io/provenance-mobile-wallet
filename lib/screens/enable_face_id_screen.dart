import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

abstract class EnableFaceIdBloc {
  ValueStream<BiometryType> get biometryType;
  Future<void> submitEnableFaceId({
    required BuildContext context,
    required bool useBiometry,
  });
}

class EnableFaceIdScreen extends StatelessWidget {
  const EnableFaceIdScreen({
    required EnableFaceIdBloc bloc,
    Key? key,
  })  : _bloc = bloc,
        super(key: key);

  final EnableFaceIdBloc _bloc;

  static final keyEnableButton = ValueKey('$EnableFaceIdScreen.enable_button');
  static final keySkipButton = ValueKey('$EnableFaceIdScreen.skip_button');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BiometryType>(
        initialData: _bloc.biometryType.valueOrNull,
        stream: _bloc.biometryType,
        builder: (context, snapshot) {
          final biometryType = snapshot.data;
          if (biometryType == null) {
            return Container();
          }

          String header;
          String title;
          String message;
          String icon;

          switch (biometryType) {
            case BiometryType.faceId:
              header = Strings.of(context).faceId;
              title = Strings.of(context).useFaceIdTitle;
              message = Strings.of(context).useYourFaceId;
              icon = PwIcons.faceId;
              break;
            case BiometryType.touchId:
              header = Strings.of(context).touchId;
              title = Strings.of(context).useTouchIdTitle;
              message = Strings.of(context).useYourFingerPrint;
              icon = PwIcons.touchId;
              break;
            case BiometryType.unknown:
            case BiometryType.none:
              header = Strings.of(context).useBiometryTitle;
              title = Strings.of(context).useBiometryTitle;
              message = Strings.of(context).useBiometryMessage;
              icon = PwIcons.faceId;
              break;
          }

          Widget skipButton;
          skipButton = biometryType == BiometryType.none
              ? PwTextButton.primaryAction(
                  key: keySkipButton,
                  context: context,
                  onPressed: () {
                    _submit(
                      context: context,
                      useBiometry: false,
                    );
                  },
                  text: Strings.of(context).skipForNow,
                )
              : PwTextButton(
                  key: keySkipButton,
                  child: PwText(
                    Strings.of(context).skipForNow,
                    style: PwTextStyle.subhead,
                    color: PwColor.neutralNeutral,
                  ),
                  onPressed: () {
                    _submit(
                      context: context,
                      useBiometry: false,
                    );
                  },
                );

          return Scaffold(
            appBar: PwAppBar(
              title: header,
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
                              icon,
                              color:
                                  Theme.of(context).colorScheme.neutralNeutral,
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
                        if (biometryType != BiometryType.none)
                          Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: PwButton(
                              key: keyEnableButton,
                              autofocus: true,
                              child: PwText(
                                Strings.of(context).enable,
                                style: PwTextStyle.bodyBold,
                                color: PwColor.neutralNeutral,
                              ),
                              onPressed: () {
                                _submit(
                                  context: context,
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
        });
  }

  void _submit({
    required BuildContext context,
    required bool useBiometry,
  }) async {
    ModalLoadingRoute.showLoading(context);

    try {
      await _bloc.submitEnableFaceId(
        context: context,
        useBiometry: useBiometry,
      );
    } finally {
      ModalLoadingRoute.dismiss(context);
    }
  }
}
