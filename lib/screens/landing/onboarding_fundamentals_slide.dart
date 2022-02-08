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
            Strings.strongFundamentals,
            style: PwTextStyle.large,
            textAlign: TextAlign.center,
            color: PwColor.white,
          ),
        ),
        SizedBox(
          height: 48,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 64,
          ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 7),
                              child: PwText(
                                _marketCap.substring(0, 1),
                                style: PwTextStyle.h4,
                                color: PwColor.white,
                              ),
                            ),
                            PwText(
                              _marketCap.substring(1),
                              style: PwTextStyle.h3,
                              color: PwColor.white,
                            ),
                          ],
                        ),
                        PwText(
                          Strings.marketCap,
                          style: PwTextStyle.m_p,
                          color: PwColor.white,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PwText(
                          '$_numValidators',
                          style: PwTextStyle.h3,
                          color: PwColor.white,
                        ),
                        PwText(
                          Strings.validators,
                          style: PwTextStyle.m_p,
                          color: PwColor.white,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PwText(
                              _transactions.substring(
                                0,
                                _transactions.length - 1,
                              ),
                              style: PwTextStyle.h3,
                              color: PwColor.white,
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: PwText(
                                _transactions
                                    .substring(_transactions.length - 1),
                                style: PwTextStyle.h4,
                                color: PwColor.white,
                              ),
                            ),
                          ],
                        ),
                        PwText(
                          Strings.transactions,
                          style: PwTextStyle.m_p,
                          color: PwColor.white,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PwText(
                              _blockTime.substring(
                                0,
                                _blockTime.length - 3,
                              ),
                              style: PwTextStyle.h3,
                              color: PwColor.white,
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: PwText(
                                _blockTime.substring(_blockTime.length - 3),
                                style: PwTextStyle.h4,
                                color: PwColor.white,
                              ),
                            ),
                          ],
                        ),
                        PwText(
                          Strings.avgBlockTime,
                          style: PwTextStyle.m_p,
                          color: PwColor.white,
                        ),
                      ],
                    ),
                  ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            right: 20,
            left: 20,
          ),
          child: PwText(
            Strings.fundamentalsDescription,
            style: PwTextStyle.m_p,
            color: PwColor.white,
            textAlign: TextAlign.center,
          ),
        ),
        VerticalSpacer.custom(
          spacing: 80,
        ),
      ],
    );
  }
}
