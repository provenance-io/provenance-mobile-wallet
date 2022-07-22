import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MultiSigInviteScreen extends StatelessWidget {
  const MultiSigInviteScreen({
    required this.number,
    required this.url,
    Key? key,
  }) : super(key: key);

  final int number;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        leadingIcon: PwIcons.back,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Spacing.xxLarge,
                  ),
                  child: Column(
                    children: [
                      PwText(
                        Strings.of(context).multiSigInviteTitlePrefix +
                            number.toString(),
                        style: PwTextStyle.title,
                        color: PwColor.neutralNeutral,
                        textAlign: TextAlign.center,
                      ),
                      VerticalSpacer.small(),
                      PwText(
                        Strings.of(context).multiSigInviteDescription,
                        style: PwTextStyle.body,
                        color: PwColor.neutralNeutral,
                        textAlign: TextAlign.center,
                      ),
                      VerticalSpacer.xxLarge(),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.neutral700,
                      ),
                      VerticalSpacer.xxLarge(),
                      Container(
                        height: 200,
                        width: 200,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: QrImage(
                          data: url,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      VerticalSpacer.xLarge(),
                      PwText(
                        Strings.of(context).multiSigInviteMessagePrefix +
                            Strings.of(context).multiSigInviteMessage,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutralNeutral,
                        textAlign: TextAlign.center,
                      ),
                      VerticalSpacer.xLarge(),
                    ],
                  ),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: Builder(builder: (context) {
                    return PwTextButton.primaryAction(
                      context: context,
                      text: Strings.of(context).multiSigInviteShareButtonLabel,
                      onPressed: () {
                        final box = context.findRenderObject() as RenderBox;

                        Share.share(
                          Strings.of(context).multiSigInviteMessage +
                              '\n' +
                              url,
                          subject: Strings.of(context).multiSigInviteSubject,
                          sharePositionOrigin:
                              box.localToGlobal(Offset.zero) & box.size,
                        );
                      },
                    );
                  }),
                ),
                VerticalSpacer.largeX4(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
