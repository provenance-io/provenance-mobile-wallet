import 'dart:async';

import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/change_pin_flow/change_pin_flow.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/profile/category_label.dart';
import 'package:provenance_wallet/screens/dashboard/profile/developer_menu.dart';
import 'package:provenance_wallet/screens/dashboard/profile/future_toggle_item.dart';
import 'package:provenance_wallet/screens/dashboard/profile/link_item.dart';
import 'package:provenance_wallet/screens/dashboard/profile/toggle_item.dart';
import 'package:provenance_wallet/services/key_value_service.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _divider = PwListDivider();
  static const _devTapsRequired = 10;
  var _devTapCount = 0;
  var _showDevMenu = false;
  final _keyValueService = get<KeyValueService>();
  Timer? _devTimer;

  @override
  void initState() {
    super.initState();

    _initDevMenu();
  }

  @override
  void dispose() {
    _stopDevTimer();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              GestureDetector(
                onTap: _onDevTap,
                child: AppBar(
                  primary: false,
                  centerTitle: true,
                  backgroundColor: Theme.of(context).colorScheme.neutral750,
                  elevation: 0.0,
                  leading: Container(),
                  title: PwText(
                    Strings.profile,
                    style: PwTextStyle.subhead,
                  ),
                ),
              ),
              CategoryLabel(Strings.security),
              _divider,
              FutureBuilder<BiometryType>(
                future: get<CipherService>().getBiometryType(),
                builder: (context, snapshot) {
                  var type = snapshot.data;
                  if (type == null || type == BiometryType.none) {
                    return Container();
                  }

                  var label = '';

                  switch (type) {
                    case BiometryType.none:
                      break;
                    case BiometryType.faceId:
                      label = Strings.faceId;
                      break;
                    case BiometryType.touchId:
                      label = Strings.touchId;
                      break;
                    case BiometryType.unknown:
                      label = Strings.biometry;
                      break;
                  }

                  return Column(
                    children: [
                      FutureToggleItem(
                        text: label,
                        getValue: () async =>
                            await get<CipherService>().getUseBiometry() ??
                            false,
                        setValue: (value) =>
                            get<CipherService>().setUseBiometry(
                          useBiometry: value,
                        ),
                      ),
                      _divider,
                    ],
                  );
                },
              ),
              StreamBuilder<WalletDetails?>(
                stream: get<WalletService>().events.selected,
                initialData: null,
                builder: (context, snapshot) {
                  var accountName = snapshot.data?.name ?? "";

                  return LinkItem(
                    text: Strings.pinCode,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePinFlow(accountName),
                        ),
                      );
                    },
                  );
                },
              ),
              _divider,
              LinkItem(
                text: Strings.resetWallets,
                onTap: () async {
                  bool shouldReset = await PwDialog.showConfirmation(
                    context,
                    title: Strings.resetWallets,
                    message: Strings.resetWalletsAreYouSure,
                    cancelText: Strings.cancel,
                    confirmText: Strings.resetWallets,
                  );
                  if (shouldReset) {
                    await get<DashboardBloc>().resetWallets();
                  }
                },
              ),
              _divider,
              CategoryLabel(Strings.general),
              _divider,
              LinkItem(
                text: Strings.aboutProvenanceBlockchain,
                onTap: () {
                  launchUrl('https://provenance.io/');
                },
              ),
              _divider,
              LinkItem(
                text: Strings.moreInformation,
                onTap: () {
                  launchUrl('https://docs.provenance.io/');
                },
              ),
              _divider,
              StreamBuilder<bool?>(
                initialData:
                    _keyValueService.streamBool(PrefKey.showAdvancedUI).value,
                stream: _keyValueService.streamBool(PrefKey.showAdvancedUI),
                builder: (context, snapshot) {
                  final show = snapshot.data ?? false;

                  return ToggleItem(
                    text: Strings.profileShowAdvancedUI,
                    value: show,
                    onChanged: (value) =>
                        _keyValueService.setBool(PrefKey.showAdvancedUI, value),
                  );
                },
              ),
              if (_showDevMenu) _divider,
              if (_showDevMenu) DeveloperMenu(),
              _divider,
            ],
          ),
        ),
      ),
    );
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _initDevMenu() async {
    final showDevMenu = await _keyValueService.getBool(PrefKey.showDevMenu);

    if (showDevMenu ?? false) {
      setState(() {
        _showDevMenu = true;
      });
    }
  }

  void _startDevTimer() {
    _devTimer = Timer(Duration(seconds: 5), () {
      _devTapCount = 0;
      _devTimer = null;
    });
  }

  void _stopDevTimer() {
    _devTimer?.cancel();
    _devTimer = null;
    _devTapCount = 0;
  }

  void _onDevTap() {
    if (_devTimer == null) {
      _startDevTimer();
    }

    _devTapCount++;

    if (_devTapCount == _devTapsRequired) {
      final showDevMenu = !_showDevMenu;
      _stopDevTimer();
      setState(() {
        _showDevMenu = showDevMenu;
      });
      _keyValueService.setBool(PrefKey.showDevMenu, showDevMenu);
    }
  }
}
