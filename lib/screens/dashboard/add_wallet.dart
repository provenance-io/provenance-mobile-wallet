import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/fw_design.dart';
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
        title: FwText(
          Strings.chooseWalletType,
          color: FwColor.globalNeutral550,
          style: FwTextStyle.h6,
        ),
        leading: IconButton(
          icon: FwIcon(
            FwIcons.back,
            size: 24,
            color: Theme.of(context).colorScheme.globalNeutral550,
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
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          VerticalSpacer.xxLarge(),
                          FwText(
                            Strings.basicWallet,
                            color: FwColor.globalNeutral550,
                            style: FwTextStyle.m,
                          ),
                          VerticalSpacer.medium(),
                          FwText(
                            Strings.standardSingleUserWallet,
                            color: FwColor.globalNeutral450,
                            style: FwTextStyle.s,
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
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          VerticalSpacer.xxLarge(),
                          FwText(
                            Strings.importRecoverWallet,
                            color: FwColor.globalNeutral550,
                            style: FwTextStyle.m,
                          ),
                          VerticalSpacer.medium(),
                          FwText(
                            Strings.importExistingWallet,
                            color: FwColor.globalNeutral450,
                            style: FwTextStyle.s,
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
