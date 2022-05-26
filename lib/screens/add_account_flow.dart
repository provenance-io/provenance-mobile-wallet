import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/screens/account_name_screen.dart';
import 'package:provenance_wallet/screens/account_setup_confirmation_screen.dart';
import 'package:provenance_wallet/screens/account_type_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/backup_complete_screen.dart';
import 'package:provenance_wallet/screens/create_passphrase_screen.dart';
import 'package:provenance_wallet/screens/enable_face_id_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_account_name_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_connect_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_create_or_join_screen.dart';
import 'package:provenance_wallet/screens/pin/confirm_pin.dart';
import 'package:provenance_wallet/screens/pin/create_pin.dart';
import 'package:provenance_wallet/screens/recover_account_screen.dart';
import 'package:provenance_wallet/screens/recover_passphrase_entry_screen/recover_passphrase_entry_screen.dart';
import 'package:provenance_wallet/screens/recovery_words/recovery_words_screen.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_confirm_screen.dart';
import 'package:provenance_wallet/util/get.dart';

abstract class AddAccountFlowNavigator {
  AddAccountFlowNavigator._();

  void showAccountType();
  void showAccountName();
  void showRecoverAccount();
  void showCreatePassphrase();
  void showRecoveryWords();
  void showRecoveryWordsConfirm();
  void showBackupComplete();
  void showCreatePin();
  void showConfirmPin();
  void showEnableFaceId();
  void showAccountSetupConfirmation();
  void showRecoverPassphraseEntry();
  void showMultiSigCreateOrJoin();
  void showMultiSigConnect();
  void showMultiSigAccountName();
  void endFlow();
}

class AddAccountFlow extends FlowBase {
  const AddAccountFlow({
    required this.origin,
    Key? key,
  }) : super(key: key);

  final AddAccountOrigin origin;

  @override
  State<StatefulWidget> createState() => AddAccountFlowState();
}

class AddAccountFlowState extends FlowBaseState<AddAccountFlow>
    implements AddAccountFlowNavigator {
  @override
  void initState() {
    super.initState();

    get.registerSingleton(
      AddAccountFlowBloc(
        navigator: this,
        origin: widget.origin,
      ),
    );
  }

  @override
  void dispose() {
    get.unregister<AddAccountFlowBloc>();

    super.dispose();
  }

  @override
  Widget createStartPage() => AccountTypeScreen();

  @override
  void showAccountName() {
    showPage((context) => AccountNameScreen());
  }

  @override
  void showCreatePassphrase() {
    showPage((context) => CreatePassphraseScreen());
  }

  @override
  void showRecoverAccount() {
    showPage((context) => RecoverAccountScreen());
  }

  @override
  void showAccountType() {
    showPage((context) => AccountTypeScreen());
  }

  @override
  void endFlow() {
    completeFlow(null);
  }

  @override
  void showRecoveryWords() {
    showPage((context) => RecoveryWordsScreen());
  }

  @override
  void showRecoveryWordsConfirm() {
    showPage((context) => RecoveryWordsConfirmScreen());
  }

  @override
  void showBackupComplete() {
    showPage((context) => BackupCompleteScreen());
  }

  @override
  void showCreatePin() {
    showPage((context) => CreatePin());
  }

  @override
  void showConfirmPin() {
    showPage((context) => ConfirmPin());
  }

  @override
  void showEnableFaceId() {
    showPage((context) => EnableFaceIdScreen());
  }

  @override
  void showAccountSetupConfirmation() {
    showPage((context) => AccountSetupConfirmationScreen());
  }

  @override
  void showRecoverPassphraseEntry() {
    showPage((context) => RecoverPassphraseEntryScreen());
  }

  @override
  void showMultiSigAccountName() {
    showPage((context) => MultiSigAccountNameScreen());
  }

  @override
  void showMultiSigCreateOrJoin() {
    showPage((context) => MultiSigCreateOrJoinScreen());
  }

  @override
  void showMultiSigConnect() {
    showPage((context) => MultiSigConnectScreen());
  }
}
