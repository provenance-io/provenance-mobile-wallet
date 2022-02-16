import 'dart:async';

import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/account_name.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard.dart';
import 'package:provenance_wallet/screens/landing/onboarding_fundamentals_slide.dart';
import 'package:provenance_wallet/screens/landing/onboarding_landing_slide.dart';
import 'package:provenance_wallet/screens/landing/onboarding_customization_slide.dart';
import 'package:provenance_wallet/screens/landing/page_indicator.dart';
import 'package:provenance_wallet/services/secure_storage_service.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/local_authentication_service.dart';
import 'package:provenance_wallet/util/strings.dart';

class Landing extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LandingState();
  }
}

class _LandingState extends State<Landing> with WidgetsBindingObserver {
  static const _inactivityTimeout = Duration(minutes: 2);

  bool _accountExists = false;
  LocalAuthenticationService _localAuth = LocalAuthenticationService();
  LocalAuthHelper _helper = LocalAuthHelper.instance;
  PageController _pageController = PageController();
  double _currentPage = 0;
  Timer? _inactivityTimer;

  @override
  void initState() {
    _pageController.addListener(_setCurrentPage);
    _localAuth.initialize();
    checkAccount();

    WidgetsBinding.instance!.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_setCurrentPage);
    _pageController.dispose();

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
    final storage = await SecureStorageService().read(StorageKey.accountName);
    if (storage != null && storage.isNotEmpty) {
      setState(() {
        _accountExists = true;
      });

      doAuth();
    }
  }

  void doAuth() {
    LocalAuthHelper.instance.auth(context, (result) {
      if (result) {
        Navigator.of(context).push(Dashboard().route());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.images.background),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VerticalSpacer.custom(spacing: 150),
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  OnboardingLandingSlide(),
                  OnboardingFundamentalsSlide(),
                  OnboardingCustomizationSlide(),
                ],
              ),
            ),
            VerticalSpacer.medium(),
            PageIndicator(currentPageIndex: _currentPage.round()),
            VerticalSpacer.large(),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwButton(
                child: PwText(
                  _accountExists ? Strings.continueName : Strings.createWallet,
                  style: PwTextStyle.m,
                  color: PwColor.white,
                ),
                onPressed: () {
                  if (_accountExists) {
                    doAuth();
                  } else {
                    Navigator.of(context).push(AccountName(
                      WalletAddImportType.onBoardingAdd,
                      currentStep: 1,
                      numberOfSteps: 4,
                    ).route());
                  }
                },
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwTextButton(
                child: PwText(
                  Strings.restoreWallet,
                  style: PwTextStyle.m,
                  color: PwColor.white,
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
            SizedBox(
              height: 40,
            ),
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
