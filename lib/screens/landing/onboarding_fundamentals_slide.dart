import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_onboarding_view.dart';
import 'package:provenance_wallet/screens/landing/landing_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingFundamentalsSlide extends StatefulWidget {
  const OnboardingFundamentalsSlide({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OnboardingFundamentalsSlideState();
  }
}

class _OnboardingFundamentalsSlideState
    extends State<OnboardingFundamentalsSlide> {
  @override
  Widget build(BuildContext context) {
    final bloc = get<LandingBloc>();

    return PwOnboardingView(children: [
      PwText(
        Strings.strongFundamentals,
        style: PwTextStyle.headline1,
        textAlign: TextAlign.center,
        color: PwColor.neutralNeutral,
      ),
      VerticalSpacer.largeX4(),
      GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisSpacing: 0.0,
        crossAxisCount: 2,
        mainAxisSpacing: Spacing.xxLarge,
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

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 7),
                        child: PwText(
                          marketCap.substring(0, 1),
                          style: PwTextStyle.h4,
                          color: PwColor.neutralNeutral,
                        ),
                      ),
                      PwText(
                        marketCap.substring(1),
                        style: PwTextStyle.h3,
                        color: PwColor.neutralNeutral,
                      ),
                    ],
                  );
                },
              ),
              PwText(
                Strings.marketCap,
                style: PwTextStyle.m,
                color: PwColor.neutralNeutral,
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
                    style: PwTextStyle.h3,
                    color: PwColor.neutralNeutral,
                  );
                },
              ),
              PwText(
                Strings.validators,
                style: PwTextStyle.m,
                color: PwColor.neutralNeutral,
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

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PwText(
                        transactions.substring(
                          0,
                          transactions.length - 1,
                        ),
                        style: PwTextStyle.h3,
                        color: PwColor.neutralNeutral,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: PwText(
                          transactions.substring(transactions.length - 1),
                          style: PwTextStyle.h4,
                          color: PwColor.neutralNeutral,
                        ),
                      ),
                    ],
                  );
                },
              ),
              PwText(
                Strings.transactions,
                style: PwTextStyle.m,
                color: PwColor.neutralNeutral,
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

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PwText(
                        blockTime.substring(
                          0,
                          blockTime.length - 3,
                        ),
                        style: PwTextStyle.h3,
                        color: PwColor.neutralNeutral,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: PwText(
                          blockTime.substring(blockTime.length - 3),
                          style: PwTextStyle.h4,
                          color: PwColor.neutralNeutral,
                        ),
                      ),
                    ],
                  );
                },
              ),
              PwText(
                Strings.avgBlockTime,
                style: PwTextStyle.m,
                color: PwColor.neutralNeutral,
              ),
            ],
          ),
        ],
      ),
      VerticalSpacer.largeX5(),
      PwText(
        Strings.fundamentalsDescription,
        style: PwTextStyle.m,
        color: PwColor.neutralNeutral,
        textAlign: TextAlign.center,
      ),
    ]);
  }
}
