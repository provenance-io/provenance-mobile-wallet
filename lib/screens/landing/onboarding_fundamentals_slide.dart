import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/network/services/stat_service.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingFundamentalsSlide extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OnboardingFundamentalsSlideState();
  }
}

class _OnboardingFundamentalsSlideState
    extends State<OnboardingFundamentalsSlide> {
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
          child: PwText(
            Strings.figureTechWallet,
            style: PwTextStyle.h3,
            textAlign: TextAlign.center,
            color: PwColor.globalNeutral550,
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
                        PwText(
                          _marketCap,
                          style: PwTextStyle.h4,
                          color: PwColor.globalNeutral450,
                        ),
                        PwText(
                          Strings.marketCap,
                          style: PwTextStyle.m,
                          color: PwColor.globalNeutral450,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PwText(
                          '$_numValidators',
                          style: PwTextStyle.h4,
                          color: PwColor.globalNeutral450,
                        ),
                        PwText(
                          Strings.validators,
                          style: PwTextStyle.m,
                          color: PwColor.globalNeutral450,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PwText(
                          _transactions,
                          style: PwTextStyle.h4,
                          color: PwColor.globalNeutral450,
                        ),
                        PwText(
                          Strings.transactions,
                          style: PwTextStyle.m,
                          color: PwColor.globalNeutral450,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PwText(
                          _blockTime,
                          style: PwTextStyle.h4,
                          color: PwColor.globalNeutral450,
                        ),
                        PwText(
                          Strings.avgBlockTime,
                          style: PwTextStyle.m,
                          color: PwColor.globalNeutral450,
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
