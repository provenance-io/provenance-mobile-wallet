import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/network/services/stat_service.dart';
import 'package:flutter_tech_wallet/util/strings.dart';

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
  void didChangeDependencies() {
    getStats();
    super.didChangeDependencies();
  }

  Future<void> getStats() async {
    setState(() {
      _isLoading = true;
    });

    StatService.getStats().then((stat) {
      setState(() {
        _marketCap = stat.marketCap;
        _transactions = stat.transactions;
        _numValidators = stat.validators;
        _blockTime = stat.blockTime;
        _isLoading = false;
      });
    }).onError((error, stackTrace) {
      // Do something with the error?
      _isLoading = false;
    });
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
            Strings.figureTechWallet,
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
                    ),
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
                          Strings.marketCap,
                          style: FwTextStyle.m,
                          color: FwColor.globalNeutral450,
                        ),
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
                          Strings.validators,
                          style: FwTextStyle.m,
                          color: FwColor.globalNeutral450,
                        ),
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
                          Strings.transactions,
                          style: FwTextStyle.m,
                          color: FwColor.globalNeutral450,
                        ),
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
                          Strings.avgBlockTime,
                          style: FwTextStyle.m,
                          color: FwColor.globalNeutral450,
                        ),
                      ],
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}
