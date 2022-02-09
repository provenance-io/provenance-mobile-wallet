import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

import 'fundamentals_bloc.dart';

class OnboardingFundamentalsSlide extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OnboardingFundamentalsSlideState();
  }
}

class _OnboardingFundamentalsSlideState
    extends State<OnboardingFundamentalsSlide> {

  @override
  void initState() {
    super.initState();

    get.registerLazySingleton(() => FundamentalsBloc());
    get<FundamentalsBloc>().load();
  }

  @override
  void dispose() {
    get.unregister<FundamentalsBloc>();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = get<FundamentalsBloc>();

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
            crossAxisCount: 2,
            mainAxisSpacing: 0.0,
            childAspectRatio: 1.89,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<String>(
                    initialData: bloc.marketCap.value,
                    stream: bloc.marketCap,
                    builder: (context, snapshot) {
                      String marketCap = snapshot.data ?? "";

                      return PwText(
                        marketCap,
                        style: PwTextStyle.h4,
                        color: PwColor.globalNeutral450,
                      );
                    },
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
                  StreamBuilder<int>(
                    initialData: bloc.validatorsCount.value,
                    stream: bloc.validatorsCount,
                    builder: (context, snapshot) {
                      int numValidators = snapshot.data ?? 0;

                      return PwText(
                        '$numValidators',
                        style: PwTextStyle.h4,
                        color: PwColor.globalNeutral450,
                      );
                    },
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
                  StreamBuilder<String>(
                    initialData: bloc.transactions.value,
                    stream: bloc.transactions,
                    builder: (context, snapshot) {
                      String transactions = snapshot.data ?? "";

                      return PwText(
                        transactions,
                        style: PwTextStyle.h4,
                        color: PwColor.globalNeutral450,
                      );
                    },
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
                  StreamBuilder<String>(
                    initialData: bloc.blockTime.value,
                    stream: bloc.blockTime,
                    builder: (context, snapshot) {
                      String blockTime = snapshot.data ?? "";

                      return PwText(
                        blockTime,
                        style: PwTextStyle.h4,
                        color: PwColor.globalNeutral450,
                      );
                    },
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
