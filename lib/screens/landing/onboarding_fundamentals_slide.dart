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

    get.registerSingleton<FundamentalsBloc>(FundamentalsBloc());
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: viewportConstraints,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: PwText(
                    Strings.strongFundamentals,
                    style: PwTextStyle.headline1,
                    textAlign: TextAlign.center,
                    color: PwColor.white,
                  ),
                ),
                VerticalSpacer.largeX4(),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: Spacing.largeX5,
                  ),
                  child: GridView.count(
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
                                      color: PwColor.white,
                                    ),
                                  ),
                                  PwText(
                                    marketCap.substring(1),
                                    style: PwTextStyle.h3,
                                    color: PwColor.white,
                                  ),
                                ],
                              );
                            },
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
                          StreamBuilder<int>(
                            initialData: bloc.validatorsCount.value,
                            stream: bloc.validatorsCount,
                            builder: (context, snapshot) {
                              int numValidators = snapshot.data ?? 0;

                              return PwText(
                                '$numValidators',
                                style: PwTextStyle.h3,
                                color: PwColor.white,
                              );
                            },
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
                                    color: PwColor.white,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: PwText(
                                      transactions
                                          .substring(transactions.length - 1),
                                      style: PwTextStyle.h4,
                                      color: PwColor.white,
                                    ),
                                  ),
                                ],
                              );
                            },
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
                                    color: PwColor.white,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: PwText(
                                      blockTime.substring(blockTime.length - 3),
                                      style: PwTextStyle.h4,
                                      color: PwColor.white,
                                    ),
                                  ),
                                ],
                              );
                            },
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
                VerticalSpacer.xxLarge(),
                VerticalSpacer.largeX5(),
              ],
            ),
          ),
        );
      },
    );
  }
}
