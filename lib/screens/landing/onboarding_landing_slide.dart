import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/screens/dashboard/dashboard.dart';
import 'package:flutter_tech_wallet/util/local_auth_helper.dart';

class OnboardingLandingSlide extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OnboardingLandingSlideState();
  }
}

class _OnboardingLandingSlideState extends State<OnboardingLandingSlide> {
  String _marketCap = "";
  int _numValidators = 0;
  String _transactions = "";
  String _blockTime = "";
  bool _isLoading = false;

  @override
  void initState() {
    getStats();
    super.initState();
  }

  Future<void> getStats() async {
    _isLoading = true;
    // TODO: Put the service call here.
    // TODO: There's something weird here with the refresh - sometimes it doesn't.r
    await Future.delayed(Duration(milliseconds: 500));
    _marketCap = '\$12.5B';
    _transactions = '395.8K';
    _numValidators = 10;
    _blockTime = '6.36 sec.';
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            crossAxisCount: _isLoading ? 1 : 2,
            mainAxisSpacing: 0.0,
            childAspectRatio: 1.89,
            children: _isLoading
                ? [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    )
                  ]
                : [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FwText(
                          _marketCap,
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
                          '$_numValidators',
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
                          _transactions,
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
                          _blockTime,
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
    );
  }
}
