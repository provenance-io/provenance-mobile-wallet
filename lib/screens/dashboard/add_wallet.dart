import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/account_name.dart';
import 'package:provenance_wallet/util/strings.dart';

class AddWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.otherBackground,
        elevation: 0.0,
        centerTitle: true,
        title: PwText(
          Strings.chooseWalletType,
          color: PwColor.neutral550,
          style: PwTextStyle.h6,
        ),
        leading: IconButton(
          icon: PwIcon(
            PwIcons.back,
            size: 24,
            color: Theme.of(context).colorScheme.neutral550,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.otherBackground,
      child: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(AccountName(
                  WalletAddImportType.dashboardAdd,
                  currentStep: 1,
                  numberOfSteps: 2,
                ).route());
              },
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.neutralNeutral,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          VerticalSpacer.xxLarge(),
                          PwText(
                            Strings.basicWallet,
                            color: PwColor.neutral550,
                            style: PwTextStyle.m,
                          ),
                          VerticalSpacer.medium(),
                          PwText(
                            Strings.standardSingleUserWallet,
                            color: PwColor.neutral450,
                            style: PwTextStyle.s,
                          ),
                          VerticalSpacer.xxLarge(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalSpacer.medium(),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(AccountName(
                  WalletAddImportType.dashboardRecover,
                  currentStep: 1,
                  numberOfSteps: 2,
                ).route());
              },
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.neutralNeutral,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          VerticalSpacer.xxLarge(),
                          PwText(
                            Strings.importRecoverWallet,
                            color: PwColor.neutral550,
                            style: PwTextStyle.m,
                          ),
                          VerticalSpacer.medium(),
                          PwText(
                            Strings.importExistingWallet,
                            color: PwColor.neutral450,
                            style: PwTextStyle.s,
                          ),
                          VerticalSpacer.xxLarge(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.otherBackground,
            ),
          ),
        ]),
      ),
    );
  }
}
