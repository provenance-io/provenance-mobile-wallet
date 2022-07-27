import 'package:provenance_wallet/common/enum/account_add_kind.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account_button.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class AccountTypeScreen extends StatelessWidget {
  AccountTypeScreen({
    required this.bloc,
    required this.includeMultiSig,
    Key? key,
  }) : super(key: key);

  static final keyBasicAccountButton =
      ValueKey('$AccountTypeScreen.basic_button');
  static final keyRecoverAccountButton =
      ValueKey('$AccountTypeScreen.recover_account_button');

  final _keyValueService = get<KeyValueService>();
  final bool includeMultiSig;
  final AddAccountFlowBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PwAppBar(
        title: Strings.accountTypeTitle,
        leadingIcon: PwIcons.back,
      ),
      backgroundColor: Theme.of(context).colorScheme.neutral750,
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.xxLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VerticalSpacer.largeX3(),
                    AccountButton(
                      key: keyBasicAccountButton,
                      name: Strings.accountTypeOptionBasicName,
                      desc: Strings.accountTypeOptionBasicDesc,
                      onPressed: () {
                        bloc.submitAccountType(
                          AccountAddKind.createSingle,
                        );
                      },
                    ),
                    VerticalSpacer.large(),
                    AccountButton(
                      key: keyRecoverAccountButton,
                      name: Strings.accountTypeOptionImportName,
                      desc: Strings.accountTypeOptionImportDesc,
                      onPressed: () {
                        bloc.submitAccountType(
                          AccountAddKind.recover,
                        );
                      },
                    ),
                    if (includeMultiSig)
                      StreamBuilder<KeyValueData<bool>>(
                          initialData: _keyValueService
                              .stream<bool>(PrefKey.enableMultiSig)
                              .valueOrNull,
                          stream: _keyValueService
                              .stream<bool>(PrefKey.enableMultiSig),
                          builder: (context, snapshot) {
                            final enable = snapshot.data?.data ?? false;
                            if (enable) {
                              return Container(
                                margin: EdgeInsets.only(
                                  top: Spacing.large,
                                ),
                                child: AccountButton(
                                  name: Strings.accountTypeOptionMultiName,
                                  desc: Strings.accountTypeOptionMultiDesc,
                                  onPressed: () {
                                    bloc.submitAccountType(
                                      AccountAddKind.createMulti,
                                    );
                                  },
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    VerticalSpacer.largeX3(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
