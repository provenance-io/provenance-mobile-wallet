import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class SendTransactionInfo {
  SendTransactionInfo({
    this.requestId = '',
    this.amount = '',
    this.fromAddress = '',
    this.toAddress = '',
    this.fee = '',
  });

  final String amount;
  final String requestId;
  final String fromAddress;
  final String toAddress;
  final String fee;
}

class SendTransactionApproval extends StatelessWidget {
  SendTransactionApproval(this.details);

  final SendTransactionInfo details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 0.0,
        centerTitle: true,
        title: PwText(
          Strings.sendTransaction,
          color: PwColor.globalNeutral600Black,
        ),
        leading: IconButton(
          icon: PwIcon(
            PwIcons.back,
            size: 24,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
          onPressed: () async {
            await get<DashboardBloc>().sendMessageFinish(
              requestId: details.requestId,
              allowed: false,
            );
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.white,
        child: Padding(
          padding: EdgeInsets.only(
            top: 40,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PwText(
                    Strings.amount,
                    style: PwTextStyle.m,
                    color: PwColor.globalNeutral350,
                  ),
                  PwText(
                    details.amount,
                    style: PwTextStyle.m,
                    color: PwColor.globalNeutral500,
                  ),
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
                  PwText(
                    Strings.fee,
                    style: PwTextStyle.m,
                    color: PwColor.globalNeutral350,
                  ),
                  PwText(
                    details.fee,
                    style: PwTextStyle.m,
                    color: PwColor.globalNeutral500,
                  ),
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
                  PwText(
                    Strings.from,
                    style: PwTextStyle.m,
                    color: PwColor.globalNeutral350,
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  Flexible(
                    child: PwText(
                      details.fromAddress,
                      style: PwTextStyle.m,
                      color: PwColor.globalNeutral500,
                    ),
                  ),
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
                  PwText(
                    Strings.to,
                    style: PwTextStyle.m,
                    color: PwColor.globalNeutral350,
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  Flexible(
                    child: PwText(
                      details.toAddress,
                      style: PwTextStyle.m,
                      color: PwColor.globalNeutral500,
                    ),
                  ),
                ],
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwButton(
                  child: PwText(
                    Strings.approve,
                    style: PwTextStyle.mBold,
                    color: PwColor.white,
                  ),
                  onPressed: () async {
                    ModalLoadingRoute.showLoading("", context);
                    await get<DashboardBloc>().sendMessageFinish(
                      requestId: details.requestId,
                      allowed: true,
                    );
                    ModalLoadingRoute.dismiss(context);
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwTextButton(
                  child: PwText(
                    Strings.reject,
                    style: PwTextStyle.mBold,
                    color: PwColor.globalNeutral450,
                  ),
                  onPressed: () async {
                    ModalLoadingRoute.showLoading("", context);
                    // await get<WalletService>().sendMessageFinish(
                    //   requestId: details.requestId,
                    //   allowed: false,
                    // );
                    ModalLoadingRoute.dismiss(context);
                    Navigator.of(context).pop(false);
                  },
                ),
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
