import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/extension/list_extension.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_screen.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/invite_link_util.dart';
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
  final _multiSigService = get<MultiSigService>();

  late final Future<List<CosignerData>> _getCosignersFuture;

  @override
  void initState() {
    super.initState();

    _getCosignersFuture = _getCosigners();
  }

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
        title: Strings.of(context).multiSigCreationStatusTitle,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Spacing.large,
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
                    Strings.of(context).multiSigCreationStatusMessage,
                    style: PwTextStyle.h4,
                    color: PwColor.neutralNeutral,
                    textAlign: TextAlign.left,
                  ),
                  VerticalSpacer.large(),
                  PwText(
                    Strings.of(context).multiSigCreationStatusDescription,
                    style: PwTextStyle.body,
                    color: PwColor.neutralNeutral,
                    textAlign: TextAlign.left,
                  ),
                  VerticalSpacer.largeX3(),
                  PwText(
                    Strings.of(context).multiSigCreationStatusListHeading,
                    style: PwTextStyle.bodyBold,
                    color: PwColor.neutralNeutral,
                    textAlign: TextAlign.left,
                  ),
                  VerticalSpacer.large(),
                  FutureBuilder<List<CosignerData>>(
                    future: _getCosignersFuture,
                    builder: (context, snapshot) {
                      final cosigners = snapshot.data;

                      if (cosigners == null) {
                        return Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (cosigners.isEmpty) {
                        return PwText(
                          Strings.of(context)
                              .multiSigCreationStatusGetStatusError,
                          style: PwTextStyle.body,
                          color: PwColor.negative350,
                        );
                      }

                      final widgets = <Widget>[];
                      for (var i = 0; i < cosigners.length; i++) {
                        final cosigner = cosigners[i];

                        String? description;
                        if (cosigner.isSelf) {
                          description =
                              Strings.of(context).multiSigInviteCosignerSelf;
                        } else if (cosigner.address != null) {
                          description = abbreviateAddress(cosigner.address!);
                        }

                        widgets.add(divider);
                        widgets.add(
                          _CoSigner(
                            number: i + 1,
                            address: cosigner.address,
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
                      Strings.of(context).transactionBackToDashboard,
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
      final remoteAccount = await _multiSigService.getAccount(
        remoteId: account.remoteId,
        signerPublicKey: account.linkedAccount.publicKey,
      );

      if (remoteAccount != null) {
        final coin = remoteAccount.coin;

        final signers = remoteAccount.signers;
        signers.sortAscendingBy((e) => e.signerOrder);

        for (var signer in remoteAccount.signers) {
          final inviteLink = createInviteLink(signer.inviteId, coin);
          final signerAddress = signer.publicKey?.address;

          cosigners.add(
            CosignerData(
              isSelf: signerAddress == account.linkedAccount.publicKey.address,
              inviteLink: inviteLink,
              address: signer.publicKey?.address,
            ),
          );
        }
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
    required this.address,
    this.inviteLink,
    this.description,
    Key? key,
  }) : super(key: key);

  final String? address;
  final int number;
  final String? description;
  final String? inviteLink;

  @override
  Widget build(BuildContext context) {
    final checked = address != null;

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
                  Strings.of(context).multiSigInviteCosignerPrefix +
                      number.toString(),
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
