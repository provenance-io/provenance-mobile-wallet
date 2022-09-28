import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow.dart';
import 'package:provenance_wallet/screens/home/settings/information_screen.dart';
import 'package:provenance_wallet/screens/home/settings/settings_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/screens/home/view_more/hidden_proposal_creation/hidden_proposal_creation_screen.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class ViewMoreTab extends StatefulWidget {
  const ViewMoreTab({
    Key? key,
    required this.onFlowCompletion,
  }) : super(key: key);

  final Function onFlowCompletion;

  @override
  State<StatefulWidget> createState() => _ViewMoreTabState();
}

class _ViewMoreTabState extends State<ViewMoreTab> {
  final keyValueService = get<KeyValueService>();
  final accountService = get<AccountService>();
  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Scaffold(
      appBar: PwAppBar(
        title: strings.homeScreenMore,
        hasIcon: false,
        style: PwTextStyle.footnote,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.large,
              ),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PwText(
                          strings.viewMoreScreenEcosystem,
                          style: PwTextStyle.subhead,
                          textAlign: TextAlign.start,
                        ),
                        VerticalSpacer.large(),
                        _getLink(
                          PwIcons.coinsOutline,
                          strings.staking,
                          Provider<StakingScreenBloc>(
                            lazy: true,
                            dispose: (_, bloc) => bloc.onDispose(),
                            create: (context) {
                              return StakingScreenBloc(
                                  onFlowCompletion: widget.onFlowCompletion);
                            },
                            child: StakingScreen(),
                          ),
                        ),
                        _getLink(
                          PwIcons.copy,
                          strings.governanceProposals,
                          ProposalsFlow(),
                        ),
                        StreamBuilder<KeyValueData<bool>>(
                          initialData: keyValueService
                              .stream<bool>(PrefKey.allowProposalCreation)
                              .valueOrNull,
                          stream: keyValueService
                              .stream<bool>(PrefKey.allowProposalCreation),
                          builder: (context, snapshot) {
                            final isTestNet =
                                accountService.events.selected.value?.coin ==
                                    Coin.testNet;
                            final allowProposalCreation =
                                snapshot.data?.data ?? false;
                            if (!allowProposalCreation && isTestNet) {
                              return Container();
                            }

                            return _getLink(
                              PwIcons.userAccount,
                              strings.viewMoreTabCreateProposal,
                              HiddenProposalCreationScreen(),
                            );
                          },
                        ),
                        VerticalSpacer.xxLarge(),
                        PwText(
                          strings.viewMoreScreenGeneral,
                          style: PwTextStyle.subhead,
                          textAlign: TextAlign.start,
                        ),
                        VerticalSpacer.large(),
                        _getLink(
                          PwIcons.information,
                          strings.viewMoreScreenInformation,
                          InformationScreen(),
                        ),
                        _getLink(
                          PwIcons.gear,
                          strings.globalSettings,
                          SettingsScreen(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLink(String icon, String name, Widget screen) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 1,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(screen.route());
        },
        child: Container(
          color: Theme.of(context).colorScheme.neutral700,
          padding: EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: Spacing.large,
                ),
                child: PwIcon(
                  icon,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                ),
              ),
              PwText(
                name,
                style: PwTextStyle.body,
                overflow: TextOverflow.fade,
                color: PwColor.neutralNeutral,
                softWrap: false,
              ),
              Expanded(child: Container()),
              SizedBox(
                width: 60,
                height: 60,
                child: Center(
                  child: PwIcon.only(
                    PwIcons.caret,
                    width: 4,
                    height: 8,
                    color: Theme.of(context).colorScheme.neutralNeutral,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
