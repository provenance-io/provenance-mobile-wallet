import 'dart:async';

import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/account_name.dart';
import 'package:provenance_wallet/screens/landing/landing_bloc.dart';
import 'package:provenance_wallet/screens/landing/onboarding_customization_slide.dart';
import 'package:provenance_wallet/screens/landing/onboarding_fundamentals_slide.dart';
import 'package:provenance_wallet/screens/landing/onboarding_landing_slide.dart';
import 'package:provenance_wallet/screens/landing/page_indicator.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_authentication_service.dart';
import 'package:provenance_wallet/util/strings.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LandingScreenState();
  }
}

class _LandingScreenState extends State<LandingScreen>
    with WidgetsBindingObserver {
  static const _inactivityTimeout = Duration(minutes: 2);

  final _localAuth = LocalAuthenticationService();
  final _pageController = PageController();
  double _currentPage = 0;
  Timer? _inactivityTimer;

  @override
  void initState() {
    _pageController.addListener(_setCurrentPage);
    _localAuth.initialize();
    get.registerSingleton<LandingBloc>(LandingBloc());
    get<LandingBloc>().load();
    checkAccount();

    WidgetsBinding.instance!.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_setCurrentPage);
    _pageController.dispose();
    get.unregister<LandingBloc>();
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _inactivityTimer ??= Timer(_inactivityTimeout, () {
          _inactivityTimer = null;
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
        break;
      case AppLifecycleState.resumed:
        _inactivityTimer?.cancel();
        _inactivityTimer = null;
        break;
      default:
    }
  }

  void checkAccount() async {
    final bloc = get<LandingBloc>();

    if (bloc.hasStorage.value) {
      bloc.doAuth(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var bloc = get<LandingBloc>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.images.background),
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
              child: StreamBuilder<bool>(
                initialData: bloc.hasStorage.value,
                stream: bloc.hasStorage,
                builder: (context, snapshot) {
                  var hasStorage = snapshot.data ?? false;

                  return PwPrimaryButton.fromString(
                    text: hasStorage
                        ? Strings.continueName
                        : Strings.createWallet,
                    onPressed: () {
                      if (hasStorage) {
                        bloc.doAuth(context);
                      } else {
                        Navigator.of(context).push(AccountName(
                          WalletAddImportType.onBoardingAdd,
                          currentStep: 1,
                          numberOfSteps: 4,
                        ).route());
                      }
                    },
                  );
                },
              ),
            ),
            VerticalSpacer.large(),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwTextButton(
                child: PwText(
                  Strings.recoverWallet,
                  style: PwTextStyle.body,
                  color: PwColor.neutralNeutral,
                ),
                onPressed: () {
                  Navigator.of(context).push(AccountName(
                    WalletAddImportType.onBoardingRecover,
                    currentStep: 1,
                    numberOfSteps: 4,
                  ).route());
                },
              ),
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
