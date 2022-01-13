import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/common/widgets/modal_loading.dart';
import 'package:flutter_tech_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class SendTransactionInfo {
  final String amount;
  final String requestId;
  final String fromAddress;
  final String toAddress;
  final String fee;

  SendTransactionInfo(
      {this.requestId = '',
      this.amount = '',
      this.fromAddress = '',
      this.toAddress = '',
      this.fee = ''});
}

class SendTransactionApproval extends StatelessWidget {
  final SendTransactionInfo details;

  SendTransactionApproval(this.details);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: FwText(Strings.sendTransaction,
              color: FwColor.globalNeutral600Black),
          leading: IconButton(
              icon: FwIcon(
                FwIcons.back,
                size: 24,
                color: Color(0xFF3D4151),
              ),
              onPressed: () async {
                await ProvWalletFlutter.sendMessageFinish(
                    details.requestId, false);
                Navigator.of(context).pop();
              }),
        ),
        body: Container(
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FwText(
                          Strings.amount,
                          style: FwTextStyle.m,
                          color: FwColor.globalNeutral350,
                        ),
                        FwText(details.amount,
                            style: FwTextStyle.m,
                            color: FwColor.globalNeutral500)
                      ],
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black12,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FwText(
                          Strings.fee,
                          style: FwTextStyle.m,
                          color: FwColor.globalNeutral350,
                        ),
                        FwText(details.fee,
                            style: FwTextStyle.m,
                            color: FwColor.globalNeutral500)
                      ],
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black12,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FwText(
                          Strings.from,
                          style: FwTextStyle.m,
                          color: FwColor.globalNeutral350,
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        Flexible(
                            child: FwText(details.fromAddress,
                                style: FwTextStyle.m,
                                color: FwColor.globalNeutral500))
                      ],
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black12,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FwText(
                          Strings.to,
                          style: FwTextStyle.m,
                          color: FwColor.globalNeutral350,
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        Flexible(
                            child: FwText(details.toAddress,
                                style: FwTextStyle.m,
                                color: FwColor.globalNeutral500))
                      ],
                    ),
                    Expanded(child: Container()),
                    Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: FwButton(
                            child: FwText(
                              Strings.approve,
                              style: FwTextStyle.mBold,
                              color: FwColor.white,
                            ),
                            onPressed: () async {
                              ModalLoadingRoute.showLoading("", context);
                              await ProvWalletFlutter.sendMessageFinish(
                                  details.requestId, true);
                              ModalLoadingRoute.dismiss(context);
                              Navigator.of(context).pop();
                            })),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: FwTextButton(
                            child: FwText(
                              Strings.reject,
                              style: FwTextStyle.mBold,
                              color: FwColor.globalNeutral450,
                            ),
                            onPressed: () async {
                              ModalLoadingRoute.showLoading("", context);
                              await ProvWalletFlutter.sendMessageFinish(
                                  details.requestId, false);
                              ModalLoadingRoute.dismiss(context);
                              Navigator.of(context).pop();
                            })),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ))));
  }
}
