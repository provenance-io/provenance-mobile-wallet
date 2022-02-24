import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send/recent_send_list.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_asset_list.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class SendScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PwText(Strings.sendTitle),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.medium,
            horizontal: Spacing.medium,
          ),
          child: SendPage(),
        ),
      ),
    );
  }
}

class SendPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendPageState();
}

class SendPageState extends State<SendPage> {
  final _addressController = TextEditingController();
  final _denomNotifier = ValueNotifier<SendAsset?>(null);
  final _recentSends = ValueNotifier<List<RecentAddress>>(<RecentAddress>[]);
  final _assets = ValueNotifier<List<SendAsset>>(<SendAsset>[]);
  SendBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = get.get<SendBloc>();
    assert(_bloc != null);

    _bloc!.stream.listen((state) {
      _recentSends.value = state.recentSendAddresses;
      _assets.value = state.availableAssets;
    });

    _bloc!.load();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const LabelPadding = EdgeInsets.fromLTRB(0, Spacing.medium, 0, Spacing.small,);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: LabelPadding,
          child: PwText(Strings.sendPageSelectAmount),
        ),
        ValueListenableBuilder<List<SendAsset>>(
          valueListenable: _assets,
          builder: (context, assets, child,) {
            return ValueListenableBuilder<SendAsset?>(
              valueListenable: _denomNotifier,
              builder: (context, selectedAsset, child,) {
                return SendAssetList(
                  assets,
                  selectedAsset,
                  (newAsset) => _denomNotifier.value = newAsset,
                );
              },
            );
          },
        ),
        Padding(
          padding: LabelPadding,
          child: PwText(Strings.sendPageSendToAddressLabel),
        ),
        Row(
          children: [
            Expanded(
                child: TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: Strings.sendPageScanQrCode,
                  ),
                ),
            ),
            HorizontalSpacer.medium(),
            Container(
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: theme.inputDecorationTheme.border?.borderSide ?? BorderSide(),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                    Icons.qr_code,
                ),
                onPressed: () async {
                  try {
                    final newAddress = await _bloc!.scanAddress();
                    if(newAddress?.isNotEmpty ?? false) {
                      _addressController.text = newAddress!;
                    }
                  }
                  catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => ErrorDialog(error: e.toString(),),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: LabelPadding,
          child: PwText(Strings.sendPageRecentAddress),
        ),
        Expanded(
          child: ValueListenableBuilder<List<RecentAddress>>(
            valueListenable: _recentSends,
            builder: (context, value, child,) => RecentSendList(
              value,
              _onRecentAddressClicked,
              _onViewAllClicked,
              key: ValueKey("RecentAddresses"),
            ),
          ),
        ),
        PwButton(
            child: PwText(Strings.nextButtonLabel),
            onPressed: _next,
        ),
        VerticalSpacer.large(),
      ],
    );
  }

  void _onViewAllClicked() {
    _bloc?.showAllRecentSends();
  }

  void _onRecentAddressClicked(RecentAddress recentAddress) {
    _addressController.text = recentAddress.address;
  }

  Future<void> _next() async {
    try {
      await _bloc!.next(_addressController.text, _denomNotifier.value);
    }
    catch(e) {
      showDialog(
          context: context,
          builder: (context) => ErrorDialog(error: e.toString(),),
      );
    }
  }
}