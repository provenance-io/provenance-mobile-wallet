import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/add_account_flow.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/landing/landing_bloc.dart';
import 'package:provenance_wallet/screens/landing/onboarding_customization_slide.dart';
import 'package:provenance_wallet/screens/landing/onboarding_fundamentals_slide.dart';
import 'package:provenance_wallet/screens/landing/onboarding_landing_slide.dart';
import 'package:provenance_wallet/screens/landing/page_indicator.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({
    Key? key,
  }) : super(key: key);

  static final keyRecoverAccountButton =
      ValueKey('$LandingScreen.recover_account_button');

  @override
  State<StatefulWidget> createState() {
    return _LandingScreenState();
  }
}

class _LandingScreenState extends State<LandingScreen> {
  final _pageController = PageController();
  double _currentPage = 0;
  final _bloc = LandingBloc();

  @override
  void initState() {
    _pageController.addListener(_setCurrentPage);
    get.registerSingleton(_bloc);

    _bloc.load();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_setCurrentPage);
    _pageController.dispose();
    get.unregister<LandingBloc>();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authHelper = get<LocalAuthHelper>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.imagePaths.background),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: const [
                  OnboardingLandingSlide(),
                  OnboardingFundamentalsSlide(),
                  OnboardingCustomizationSlide(),
                ],
              ),
            ),
            PageIndicator(currentPageIndex: _currentPage.round()),
            VerticalSpacer.xxLarge(),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: StreamBuilder<AuthStatus>(
                initialData: authHelper.status.value,
                stream: authHelper.status,
                builder: (context, snapshot) {
                  final status = snapshot.data;
                  if (status == AuthStatus.noLockScreen) {
                    return PwText(
                      Strings.lockScreenRequired,
                      textAlign: TextAlign.center,
                    );
                  }

                  var hasAccount = status != AuthStatus.noAccount;

                  return PwPrimaryButton.fromString(
                    text:
                        hasAccount ? Strings.continueName : Strings.addAccount,
                    onPressed: () {
                      if (hasAccount) {
                        _bloc.doAuth(context);
                      } else {
                        Navigator.of(context).push(
                          AddAccountFlow(
                            origin: AddAccountOrigin.landing,
                          ).route(),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            StreamBuilder<AuthStatus>(
              initialData: authHelper.status.value,
              stream: authHelper.status,
              builder: (context, snapshot) {
                final status = snapshot.data;
                if (status == AuthStatus.noLockScreen) {
                  return Container(
                    margin: EdgeInsets.only(
                      top: Spacing.large,
                      left: 20,
                      right: 20,
                    ),
                    child: PwPrimaryButton.fromString(
                      text: Strings.refresh,
                      onPressed: () async {
                        ModalLoadingRoute.showLoading('', context);
                        // Give the loading modal time to display
                        await Future.delayed(Duration(milliseconds: 500));
                        ModalLoadingRoute.dismiss(context);
                      },
                    ),
                  );
                }

                return Container();
              },
            ),
            VerticalSpacer.largeX4(),
          ],
        ),
      ),
    );
  }

  void _setCurrentPage() {
    setState(() {
      _currentPage = _pageController.page ?? 0;
    });
  }
}
