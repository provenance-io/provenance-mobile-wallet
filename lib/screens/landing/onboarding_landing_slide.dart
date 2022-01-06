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
  double marketCap = 0;
  int numValidators = 0;
  double numTransactions = 0;
  String blockTime = "";
  bool _isLoading = false;

  @override
  void initState() {
    getStats();
    super.initState();
  }

  void getStats() {
    _isLoading = true;
    // TODO: Put the service call here.
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
    );
  }
}
