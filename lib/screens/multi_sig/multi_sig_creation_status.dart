import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_screen.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigCreationStatus extends StatefulWidget {
  const MultiSigCreationStatus({
    required this.accountId,
    Key? key,
  }) : super(key: key);

  final String accountId;

  @override
  State<MultiSigCreationStatus> createState() => _MultiSigCreationStatusState();
}

class _MultiSigCreationStatusState extends State<MultiSigCreationStatus> {
  final _accountService = get<AccountService>();

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
                  FutureBuilder<List<CosignerData>>(
                    initialData: const [],
                    future: _getCosigners(),
                    builder: (context, snapshot) {
                      final cosigners = snapshot.data!;

                      final widgets = <Widget>[];
                      for (var i = 0; i < cosigners.length; i++) {
                        final cosigner = cosigners[i];

                        final description = cosigner.isSelf
                            ? Strings.multiSigInviteCosignerSelf
                            : null;

                        widgets.add(divider);
                        widgets.add(
                          _CoSigner(
                            number: i + 1,
                            checked: cosigner.isSelf,
                            description: description,
                            inviteLink: cosigner.inviteLink,
                          ),
                        );
                      }
                      return Column(
                        children: widgets,
                      );
                    },
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
                      Navigator.of(context).pop();
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

  Future<List<CosignerData>> _getCosigners() async {
    final cosigners = <CosignerData>[];

    final account =
        await _accountService.getAccount(widget.accountId) as MultiAccount?;

    if (account != null) {
      final linkedAccount = account.linkedAccount;
      final self = CosignerData(
        isSelf: true,
        name: linkedAccount.name,
        address: linkedAccount.publicKey.address,
      );

      cosigners.add(self);

      final cosignerCount = account.cosignerCount;
      for (var i = 1; i < cosignerCount; i++) {
        cosigners.add(
          CosignerData(
            isSelf: false,
            inviteLink: account.inviteLinks[i - 1],
          ),
        );
      }
    }

    return cosigners;
  }
}

class CosignerData {
  CosignerData({
    required this.isSelf,
    this.inviteLink,
    this.name,
    this.address,
  });

  final bool isSelf;
  final String? inviteLink;
  final String? name;
  final String? address;
}

class _CoSigner extends StatelessWidget {
  const _CoSigner({
    required this.number,
    required this.checked,
    this.inviteLink,
    this.description,
    Key? key,
  }) : super(key: key);

  final bool checked;
  final int number;
  final String? description;
  final String? inviteLink;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: checked || inviteLink == null
          ? null
          : () {
              Navigator.of(context).push(
                MultiSigInviteScreen(
                  number: number,
                  url: inviteLink!,
                ).route(),
              );
            },
      style: ButtonStyle(
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
          ),
          HorizontalSpacer.large(),
          Expanded(
            child: Column(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwText(
                  Strings.multiSigInviteCosignerPrefix + number.toString(),
                  style: PwTextStyle.bodyBold,
                  color: PwColor.neutralNeutral,
                ),
                if (description != null) VerticalSpacer.small(),
                if (description != null)
                  PwText(
                    description!,
                    style: PwTextStyle.footnote,
                    color: PwColor.neutral200,
                  ),
              ],
            ),
          ),
          if (!checked)
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
