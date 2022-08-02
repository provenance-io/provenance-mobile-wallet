import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send/recent_send_list.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_asset_list.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).sendTitle,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.medium,
          horizontal: Spacing.medium,
        ),
        child: SendPage(),
      ),
    );
  }
}

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

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
      _denomNotifier.value = (state.availableAssets.isNotEmpty)
          ? state.availableAssets.first
          : null;
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
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwText(Strings.of(context).sendPageSelectAsset),
          VerticalSpacer.small(),
          ValueListenableBuilder<List<SendAsset>>(
            valueListenable: _assets,
            builder: (
              context,
              assets,
              child,
            ) {
              return ValueListenableBuilder<SendAsset?>(
                valueListenable: _denomNotifier,
                builder: (
                  context,
                  selectedAsset,
                  child,
                ) {
                  return SendAssetList(
                    assets,
                    selectedAsset,
                    (newAsset) => _denomNotifier.value = newAsset,
                  );
                },
              );
            },
          ),
          VerticalSpacer.xxLarge(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: PwTextFormField(
                  label: Strings.of(context).sendPageSendToAddressLabel,
                  controller: _addressController,
                  hint: Strings.of(context).sendPageScanQrCode,
                ),
              ),
              HorizontalSpacer.medium(),
              IconButton(
                padding: EdgeInsets.zero,
                icon: PwIcon(
                  PwIcons.qr,
                  color: theme.colorScheme.neutralNeutral,
                  size: 48.0,
                ),
                onPressed: () async {
                  try {
                    final newAddress = await _bloc!.scanAddress();
                    if (newAddress?.isNotEmpty ?? false) {
                      _addressController.text = newAddress!;
                    }
                  } catch (e) {
                    showDialog(
                      useSafeArea: true,
                      context: context,
                      builder: (context) => ErrorDialog(
                        error: e.toString(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          VerticalSpacer.xxLarge(),
          PwText(Strings.of(context).sendPageRecentAddress),
          VerticalSpacer.small(),
          Expanded(
            child: ValueListenableBuilder<List<RecentAddress>>(
              valueListenable: _recentSends,
              builder: (
                context,
                value,
                child,
              ) =>
                  RecentSendList(
                value,
                _onRecentAddressClicked,
                _onViewAllClicked,
                key: ValueKey("RecentAddresses"),
              ),
            ),
          ),
          VerticalSpacer.xxLarge(),
          PwButton(
            child: PwText(Strings.of(context).nextButtonLabel),
            onPressed: _next,
          ),
          VerticalSpacer.large(),
        ],
      ),
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
    } catch (e) {
      showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => ErrorDialog(
          error: e.toString(),
        ),
      );
    }
  }
}
