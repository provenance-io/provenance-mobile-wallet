import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/global_settings/global_settings_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen.dart';
import 'package:provenance_wallet/util/strings.dart';

class ViewMoreTab extends StatefulWidget {
  const ViewMoreTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewMoreTabState();
}

class _ViewMoreTabState extends State<ViewMoreTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.viewMore,
        hasIcon: false,
        style: PwTextStyle.footnote,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VerticalSpacer.large(),
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
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            bottom: 1,
                          ),
                          child: _getLink(
                            PwIcons.coinsOutline,
                            Strings.staking,
                            StakingScreen(),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            bottom: 1,
                          ),
                          child: _getLink(
                            PwIcons.gear,
                            Strings.globalSettings,
                            GlobalSettingsScreen(),
                          ),
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
    return GestureDetector(
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
    );
  }
}
