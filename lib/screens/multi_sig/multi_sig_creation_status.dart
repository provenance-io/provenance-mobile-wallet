import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigCreationStatus extends StatefulWidget {
  const MultiSigCreationStatus({Key? key}) : super(key: key);

  @override
  State<MultiSigCreationStatus> createState() => _MultiSigCreationStatusState();
}

class _MultiSigCreationStatusState extends State<MultiSigCreationStatus> {
  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      thickness: 1,
      height: 1,
      color: Theme.of(context).colorScheme.neutral600,
    );

    return Scaffold(
      appBar: PwAppBar(
        leadingIcon: PwIcons.close,
        title: Strings.multiSigCreationStatusTitle,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Spacing.xxLarge,
              ),
              child: Column(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerticalSpacer.large(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.imagePaths.multiSigInvite,
                        width: 180,
                      ),
                    ],
                  ),
                  VerticalSpacer.large(),
                  PwText(
                    Strings.multiSigCreationStatusMessage,
                    style: PwTextStyle.h4,
                    color: PwColor.neutralNeutral,
                    textAlign: TextAlign.left,
                  ),
                  VerticalSpacer.large(),
                  PwText(
                    Strings.multiSigCreationStatusDescription,
                    style: PwTextStyle.body,
                    color: PwColor.neutralNeutral,
                    textAlign: TextAlign.left,
                  ),
                  VerticalSpacer.largeX3(),
                  PwText(
                    Strings.multiSigCreationStatusListHeading,
                    style: PwTextStyle.bodyBold,
                    color: PwColor.neutralNeutral,
                    textAlign: TextAlign.left,
                  ),
                  VerticalSpacer.large(),
                  divider,
                  _CoSigner(
                    checked: true,
                  ),
                  divider,
                  _CoSigner(
                    checked: false,
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  VerticalSpacer.xxLarge(),
                  PwButton.alternate(
                    child: PwText(
                      Strings.transactionBackToDashboard,
                      style: PwTextStyle.bodyBold,
                      color: PwColor.neutralNeutral,
                    ),
                    onPressed: () {
                      //
                    },
                  ),
                  VerticalSpacer.largeX4(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoSigner extends StatelessWidget {
  const _CoSigner({
    required this.checked,
    Key? key,
  }) : super(key: key);

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        //
      },
      style: ButtonStyle(
        // shape: MaterialStateProperty.resolveWith(
        //   (states) => RoundedRectangleBorder(),
        // ),
        backgroundColor: MaterialStateProperty.all(
          Colors.transparent,
        ),
        elevation: MaterialStateProperty.all(0),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            vertical: 20,
          ),
        ),
      ),
      child: Row(
        children: [
          PwIcon(
            checked ? PwIcons.circleChecked : PwIcons.circleUnchecked,
            color: checked
                ? Color(0XFF28CEA8)
                : Theme.of(context).colorScheme.notice350,
            // color: Theme.of(context).colorScheme.secondary400,
          ),
          HorizontalSpacer.large(),
          Expanded(
            child: Column(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                PwText(
                  'Co-signer #1',
                  style: PwTextStyle.bodyBold,
                  color: PwColor.neutralNeutral,
                ),
                VerticalSpacer.small(),
                PwText(
                  'Self',
                  style: PwTextStyle.footnote,
                  color: PwColor.neutral200,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: PwIcon(
              PwIcons.caret,
              color: Theme.of(context).colorScheme.neutralNeutral,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}
