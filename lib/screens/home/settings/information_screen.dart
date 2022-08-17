import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/settings/category_label.dart';
import 'package:provenance_wallet/screens/home/settings/link_item.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Material(
      child: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [
                PwAppBar(
                  title: strings.viewMoreScreenInformation,
                  leadingIcon: PwIcons.back,
                ),
                CategoryLabel(strings.informationScreenAbout),
                PwListDivider(),
                LinkItem(
                  text: strings.provenanceBlockchain,
                  icon: PwIcons.newWindow,
                  onTap: () {
                    final account = get<AccountService>().events.selected.value;
                    switch (account?.coin) {
                      case Coin.mainNet:
                        launchUrl('https://provenance.io/');
                        break;
                      default:
                        launchUrl('https://test.provenance.io/');
                    }
                  },
                ),
                PwListDivider(),
                LinkItem(
                  text: strings.informationScreenDocumentation,
                  icon: PwIcons.newWindow,
                  onTap: () {
                    launchUrl('https://docs.provenance.io/');
                  },
                ),
                PwListDivider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
