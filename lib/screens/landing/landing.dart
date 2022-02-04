import 'dart:async';

import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/account_name.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard.dart';
import 'package:provenance_wallet/screens/landing/onboarding_landing_slide.dart';
import 'package:provenance_wallet/screens/landing/onboarding_manage_slide.dart';
import 'package:provenance_wallet/screens/landing/onboarding_trade_slide.dart';
import 'package:provenance_wallet/screens/landing/page_indicator.dart';
import 'package:provenance_wallet/services/secure_storage_service.dart';
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
    final storage = await SecureStorageService().read(StorageKey.privateKey);
    if (storage != null && storage.isNotEmpty) {
      setState(() {
        _accountExists = true;
      });

      doAuth();
    }
  }

  void doAuth() {
    LocalAuthHelper.instance.auth(context, (result, privateKey) {
      if (result == true) {
        Navigator.of(context).push(Dashboard().route());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.white,
        child: Padding(
          padding: EdgeInsets.only(top: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    OnboardingLandingSlide(),
                    OnboardingTradeSlide(),
                    OnboardingManageSlide(),
                  ],
                ),
              ),
              VerticalSpacer.medium(),
              PageIndicator(currentPageIndex: _currentPage.round()),
              VerticalSpacer.large(),
              _buildFaceIdButton(),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: FwButton(
                  child: FwText(
                    Strings.createWallet,
                    style: FwTextStyle.mBold,
                    color: FwColor.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(AccountName(
                      WalletAddImportType.onBoardingAdd,
                      currentStep: 1,
                      numberOfSteps: 4,
                    ).route());
                  },
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: FwTextButton(
                  child: FwText(
                    Strings.restoreWallet,
                    style: FwTextStyle.mBold,
                    color: FwColor.globalNeutral450,
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
      ),
    );
  }

  void _setCurrentPage() {
    setState(() {
      _currentPage = _pageController.page ?? 0;
    });
  }

  Widget _buildFaceIdButton() {
    if (!_accountExists) {
      return Container();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Visibility(
            visible: _accountExists,
            child: FwOutlinedButton(
              Strings.signInWithBiometric(_localAuth.authType),
              icon: FwIcon(
                FwIcons.faceScan,
                color: Theme.of(context).colorScheme.white,
              ),
              fpTextStyle: FwTextStyle.mBold,
              fpTextColor: FwColor.white,
              backgroundColor: Theme.of(context).colorScheme.globalNeutral450,
              borderColor: Theme.of(context).colorScheme.globalNeutral450,
              onPressed: () => doAuth(),
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
