import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/account_name_screen.dart';
import 'package:provenance_wallet/screens/account_setup_confirmation_screen.dart';
import 'package:provenance_wallet/screens/account_type_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/backup_complete_screen.dart';
import 'package:provenance_wallet/screens/create_passphrase_screen.dart';
import 'package:provenance_wallet/screens/enable_face_id_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_confirm_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_connect_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_count_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_create_or_join_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_join_link_screen.dart';
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
  void showAccountName(int currentStep, int totalSteps);
  void showRecoverAccount(int currentStep, int totalSteps);
  void showCreatePassphrase(int currentStep, int totalSteps);
  void showRecoveryWords(int currentStep, int totalSteps);
  void showRecoveryWordsConfirm(int currentStep, int totalSteps);
  void showBackupComplete(int currentStep, int totalSteps);
  void showCreatePin(int currentStep, int totalSteps);
  void showConfirmPin(int currentStep, int totalSteps);
  void showEnableFaceId(int currentStep, int totalSteps);
  void showAccountSetupConfirmation();
  void showRecoverPassphraseEntry(int currentStep, int totalSteps);
  void showMultiSigCreateOrJoin();
  void showMultiSigJoinLink();
  void showMultiSigConnect(int currentStep, int totalSteps);
  void showMultiSigAccountName(int currentStep, int totalSteps);
  void showMultiSigCosigners(FieldMode mode,
      [int? currentStep, int? totalSteps]);
  void showMultiSigSignatures(FieldMode mode,
      [int? currentStep, int? totalSteps]);
  void showMultiSigConfirm(int currentStep, int totalSteps);
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
  late final AddAccountFlowBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = AddAccountFlowBloc(
      navigator: this,
      origin: widget.origin,
    );

    get.registerSingleton(
      _bloc,
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
  void showAccountName(int currentStep, int totalSteps) {
    showPage(
      (context) => AccountNameScreen.single(
        currentStep: currentStep,
        totalSteps: totalSteps,
        mode: FieldMode.initial,
        leadingIcon: PwIcons.close,
      ),
    );
  }

  @override
  void showCreatePassphrase(int currentStep, int totalSteps) {
    showPage(
      (context) => CreatePassphraseScreen(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showRecoverAccount(int currentStep, int totalSteps) {
    showPage(
      (context) => RecoverAccountScreen(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
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
  void showRecoveryWords(int currentStep, int totalSteps) {
    showPage(
      (context) => RecoveryWordsScreen(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showRecoveryWordsConfirm(int currentStep, int totalSteps) {
    showPage(
      (context) => RecoveryWordsConfirmScreen(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showBackupComplete(int currentStep, int totalSteps) {
    showPage(
      (context) => BackupCompleteScreen(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showCreatePin(int currentStep, int totalSteps) {
    showPage(
      (context) => CreatePin(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showConfirmPin(int currentStep, int totalSteps) {
    showPage(
      (context) => ConfirmPin(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showEnableFaceId(int currentStep, int totalSteps) {
    showPage(
      (context) => EnableFaceIdScreen(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showAccountSetupConfirmation() {
    showPage((context) => AccountSetupConfirmationScreen());
  }

  @override
  void showRecoverPassphraseEntry(int currentStep, int totalSteps) {
    showPage(
      (context) => RecoverPassphraseEntryScreen(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showMultiSigAccountName(int currentStep, int totalSteps) {
    showPage(
      (context) => AccountNameScreen.multi(
        currentStep: currentStep,
        totalSteps: totalSteps,
        mode: FieldMode.initial,
        leadingIcon: PwIcons.back,
      ),
    );
  }

  @override
  void showMultiSigCreateOrJoin() {
    showPage((context) => MultiSigCreateOrJoinScreen());
  }

  @override
  void showMultiSigJoinLink() {
    showPage(
      (context) => MultiSigJoinLinkScreen(),
    );
  }

  @override
  void showMultiSigConnect(int currentStep, int totalSteps) {
    showPage(
      (context) => MultiSigConnectScreen(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showMultiSigCosigners(FieldMode mode,
      [int? currentStep, int? totalSteps]) {
    showPage(
      (context) => MultiSigCountScreen.cosigners(
        mode: mode,
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showMultiSigSignatures(FieldMode mode,
      [int? currentStep, int? totalSteps]) {
    showPage(
      (context) => MultiSigCountScreen.signatures(
        mode: mode,
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showMultiSigConfirm(int currentStep, int totalSteps) {
    showPage(
      (context) => MultiSigConfirmScreen(
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }
}
