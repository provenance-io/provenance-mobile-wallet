import 'dart:math';

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_corner_border.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/receive_flow/receive/receive_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).receiveTitle,
        leadingIcon: PwIcons.back,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.medium,
          horizontal: Spacing.medium,
        ),
        child: ReceivePage(),
      ),
    );
  }
}

class ReceivePage extends StatefulWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReceivePageState();
}

class ReceivePageState extends State<ReceivePage> {
  ReceiveBloc? _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = get<ReceiveBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ReceiveState>(
      stream: _bloc!.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          final state = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PwText(
                Strings.of(context).receiveMessage,
                textAlign: TextAlign.center,
                style: PwTextStyle.title,
              ),
              VerticalSpacer.large(),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final dimen = min(constraints.minWidth, width / 2);

                  return Center(
                    child: PwCornerBorder(
                      width: 4,
                      color: Colors.white,
                      child: QrImage(
                        size: dimen,
                        data: state.accountAddress,
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              VerticalSpacer.large(),
              PwText(
                Strings.of(context).receiveAccountAddressTitle,
                style: PwTextStyle.caption,
              ),
              VerticalSpacer.medium(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.fromLTRB(
                  Spacing.small,
                  0,
                  0,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: PwText(
                        state.accountAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      color: Color.fromARGB(
                        255,
                        0x2B,
                        0x2F,
                        0x3A,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.copy),
                        onPressed: _copyClicked,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _copyClicked() async {
    try {
      await _bloc!.copyAddressToClipboard();
      PwDialog.showMessage(
        context,
        message: Strings.of(context).receiveAccountAddressCopiedMessage,
      );
    } catch (e) {
      PwDialog.showError(
        context,
        message: e.toString(),
      );
    }
  }
}
