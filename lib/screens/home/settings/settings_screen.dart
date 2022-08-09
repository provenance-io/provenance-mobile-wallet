import 'package:flutter/foundation.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar_gesture_detector.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/change_pin_flow/change_pin_flow.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/settings/category_label.dart';
import 'package:provenance_wallet/screens/home/settings/developer_menu.dart';
import 'package:provenance_wallet/screens/home/settings/future_toggle_item.dart';
import 'package:provenance_wallet/screens/home/settings/link_item.dart';
import 'package:provenance_wallet/screens/home/settings/toggle_item.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/config_service/local_config.dart';
import 'package:provenance_wallet/services/crash_reporting/crash_reporting_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provenance_wallet/util/timed_counter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _divider = PwListDivider();

  final _keyValueService = get<KeyValueService>();
  late final TimedCounter _tapCounter;

  @override
  void initState() {
    super.initState();

    _tapCounter = TimedCounter(
      onSuccess: _toggleDevMenu,
    );
  }

  @override
  void dispose() {
    _tapCounter.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    final config = get<LocalConfig>();
    return Material(
      child: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [
                PwAppBarGestureDetector(
                  onTap: _tapCounter.increment,
                  child: PwAppBar(
                    title: strings.globalSettings,
                    leadingIcon: PwIcons.back,
                  ),
                ),
                CategoryLabel(
                  strings.settingsScreenPreferences,
                ),
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
                        label = strings.faceId;
                        break;
                      case BiometryType.touchId:
                        label = strings.touchId;
                        break;
                      case BiometryType.unknown:
                        label = strings.biometry;
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
                StreamBuilder<Account?>(
                  stream: get<AccountService>().events.selected,
                  initialData: null,
                  builder: (context, snapshot) {
                    var accountName = snapshot.data?.name ?? "";

                    return LinkItem(
                      text: strings.pinCode,
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
                  text: strings.resetAccounts,
                  onTap: () async {
                    bool shouldReset = await PwDialog.showConfirmation(
                      context,
                      title: strings.resetAccounts,
                      message: strings.resetAccountsAreYouSure,
                      cancelText: strings.cancel,
                      confirmText: strings.resetAccounts,
                    );
                    if (shouldReset) {
                      await get<HomeBloc>().resetAccounts();
                    }
                  },
                ),
                _divider,
                StreamBuilder<KeyValueData<bool>>(
                  initialData: _keyValueService
                      .stream<bool>(PrefKey.showAdvancedUI)
                      .valueOrNull,
                  stream: _keyValueService.stream<bool>(PrefKey.showAdvancedUI),
                  builder: (context, snapshot) {
                    final streamData = snapshot.data;
                    if (streamData == null) {
                      return Container();
                    }

                    final show = streamData.data ?? false;

                    return ToggleItem(
                      text: strings.profileShowAdvancedUI,
                      value: show,
                      onChanged: (value) => _keyValueService.setBool(
                          PrefKey.showAdvancedUI, value),
                    );
                  },
                ),
                _divider,
                StreamBuilder<KeyValueData<bool>>(
                  initialData: _keyValueService
                      .stream<bool>(PrefKey.allowCrashlitics)
                      .valueOrNull,
                  stream:
                      _keyValueService.stream<bool>(PrefKey.allowCrashlitics),
                  builder: (context, snapshot) {
                    final streamData = snapshot.data;
                    if (streamData == null) {
                      return Container();
                    }

                    final show = streamData.data ?? true;

                    return ToggleItem(
                      text: strings.profileAllowCrashlitics,
                      value: show,
                      onChanged: (value) async {
                        await _keyValueService.setBool(
                          PrefKey.allowCrashlitics,
                          value,
                        );

                        final crashReportingService =
                            get<CrashReportingService>();

                        if (value) {
                          await crashReportingService.enableCrashCollection(
                            enable: !kDebugMode,
                          );
                        } else {
                          await crashReportingService.enableCrashCollection(
                            enable: false,
                          );
                          await crashReportingService.deleteUnsentReports();
                        }
                      },
                    );
                  },
                ),
                StreamBuilder<KeyValueData<bool>>(
                  initialData: _keyValueService
                      .stream<bool>(PrefKey.showDevMenu)
                      .valueOrNull,
                  stream: _keyValueService.stream<bool>(PrefKey.showDevMenu),
                  builder: (context, snapshot) {
                    final show = snapshot.data?.data ?? false;
                    if (!show) {
                      return Container();
                    }

                    return Column(
                      children: const [
                        _divider,
                        DeveloperMenu(),
                      ],
                    );
                  },
                ),
                _divider,
                VerticalSpacer.largeX3(),
                Center(
                  child: Text(
                    strings.settingsScreenVersion(
                      config.version,
                      config.buildNumber,
                    ),
                    style: TextStyle(
                      fontFamily: 'OverpassMono',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
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

  void _toggleDevMenu() async {
    final value = await _keyValueService.getBool(PrefKey.showDevMenu) ?? false;
    await _keyValueService.setBool(PrefKey.showDevMenu, !value);
  }
}
