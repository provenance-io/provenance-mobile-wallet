import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tech_wallet/common/enum/wallet_add_import_type.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/screens/account_name.dart';
import 'package:flutter_tech_wallet/screens/backup_account_intro.dart';
import 'package:flutter_tech_wallet/screens/dashboard/dashboard.dart';
import 'package:flutter_tech_wallet/screens/restore_account_intro.dart';
import 'package:flutter_tech_wallet/services/secure_storage_service.dart';
import 'package:flutter_tech_wallet/util/local_auth_helper.dart';
import 'package:flutter_tech_wallet/util/local_authentication_service.dart';
import 'package:flutter_tech_wallet/util/strings.dart';

class Landing extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LandingState();
  }
}

class _LandingState extends State<Landing> {
  bool _accountExists = false;
  LocalAuthenticationService _localAuth = LocalAuthenticationService();
  LocalAuthHelper _helper = LocalAuthHelper.instance;
  PageController _pageController = PageController();
  double currentPage = 0;

  @override
  void initState() {
    _pageController.addListener((){
      setState(() {
        currentPage = _pageController.page ?? 0;
      });
    });
    _localAuth.initialize();
    checkAccount();
    super.initState();
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
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.only(top: 150),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Expanded(child: PageView(
                      controller: _pageController,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: FwText(
                                'Figure Tech Wallet is Lorem ipsum dolor sit amet, consectetur ',
                                style: FwTextStyle.h3,
                                textAlign: TextAlign.center,
                                color: FwColor.globalNeutral550,
                              ),
                            ),
                            SizedBox(
                              height: 48,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: GridView.count(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 0.0,
                                crossAxisCount: 2,
                                mainAxisSpacing: 0.0,
                                childAspectRatio: 1.89,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FwText(
                                        '\$12.5B',
                                        style: FwTextStyle.h4,
                                        color: FwColor.globalNeutral450,
                                      ),
                                      FwText(
                                        'Market Cap',
                                        style: FwTextStyle.m,
                                        color: FwColor.globalNeutral450,
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FwText(
                                        '10',
                                        style: FwTextStyle.h4,
                                        color: FwColor.globalNeutral450,
                                      ),
                                      FwText(
                                        'Validators',
                                        style: FwTextStyle.m,
                                        color: FwColor.globalNeutral450,
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FwText(
                                        '395.8K',
                                        style: FwTextStyle.h4,
                                        color: FwColor.globalNeutral450,
                                      ),
                                      FwText(
                                        'Transactions',
                                        style: FwTextStyle.m,
                                        color: FwColor.globalNeutral450,
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FwText(
                                        '6.36 sec.',
                                        style: FwTextStyle.h4,
                                        color: FwColor.globalNeutral450,
                                      ),
                                      FwText(
                                        'Avg Block Time',
                                        style: FwTextStyle.m,
                                        color: FwColor.globalNeutral450,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 158,
                                  width: 158,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF9196AA),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(79))),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 48,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: FwText(
                                'Trade ',
                                style: FwTextStyle.extraLarge,
                                textAlign: TextAlign.center,
                                color: FwColor.globalNeutral550,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: FwText(
                                'Trade Hash, etc lorem ipsum with confidence blah blah blah',
                                style: FwTextStyle.m,
                                textAlign: TextAlign.center,
                                color: FwColor.globalNeutral550,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 158,
                                  width: 158,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF9196AA),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(79))),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 48,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: FwText(
                                'Manage your own wallet',
                                style: FwTextStyle.extraLarge,
                                textAlign: TextAlign.center,
                                color: FwColor.globalNeutral550,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: FwText(
                                'Fully control your wallet and crypto, and manage it independently.',
                                style: FwTextStyle.m,
                                textAlign: TextAlign.center,
                                color: FwColor.globalNeutral550,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                    VerticalSpacer.medium(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                    VerticalSpacer.large(),
                    _buildFaceIdButton(),
                    Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: FwButton(
                            child: FwText(
                              'Create Wallet',
                              style: FwTextStyle.mBold,
                              color: FwColor.white,
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(AccountName(WalletAddImportType.onBoardingAdd, currentStep: 1, numberOfSteps: 4).route());
                            })),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: FwTextButton(
                            child: FwText(
                              'Restore Wallet',
                              style: FwTextStyle.mBold,
                              color: FwColor.globalNeutral450,
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(AccountName(WalletAddImportType.onBoardingRecover, currentStep: 1, numberOfSteps: 4).route());
                            })),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ))));
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
                BiometricStrings.signInWithBiometric(_localAuth.authType),
                icon: FwIcon(
                  FwIcons.faceScan,
                  color: Colors.white,
                ),
                fpTextStyle: FwTextStyle.mBold,
                fpTextColor: FwColor.white,
                backgroundColor: Theme.of(context).colorScheme.globalNeutral450,
                borderColor: Theme.of(context).colorScheme.globalNeutral450,
                onPressed: () => doAuth(),
              )),
        ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < 3; i++) {
      list.add(i == currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return Container(
      height: 10,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 0),
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive
            ? 10:8.0,
        width: isActive
            ? 12:8.0,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
            )
          ],
          shape: BoxShape.circle,
          color: isActive ? Theme.of(context).colorScheme.globalNeutral600Black : Color(0XFFC4C4C4),
        ),
      ),
    );
  }
}
