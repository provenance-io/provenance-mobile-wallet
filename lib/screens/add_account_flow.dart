import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
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
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_join_link_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_recover_screen.dart';
import 'package:provenance_wallet/screens/pin/confirm_pin.dart';
import 'package:provenance_wallet/screens/pin/create_pin.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/screens/recover_account_screen.dart';
import 'package:provenance_wallet/screens/recover_passphrase_entry_screen/recover_passphrase_entry_screen.dart';
import 'package:provenance_wallet/screens/recovery_words/recovery_words_screen.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_confirm_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/invite_link_util.dart';
import 'package:provenance_wallet/util/strings.dart';

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
  void showMultiSigJoinLink();
  void showMultiSigScanQrCode();
  void showMultiSigConnect();
  void showMultiSigRecover();
  void showMultiSigAccountName();
  void showMultiSigCosigners(FieldMode mode);
  void showMultiSigSignatures(FieldMode mode);
  void showMultiSigConfirm();
  void showMultiSigInviteReviewFlow(
    String inviteId,
    MultiSigRemoteAccount remoteAccount,
  );
  void endFlow(Account? createdAccount);
}

class AddAccountFlow extends FlowBase {
  const AddAccountFlow({
    required this.origin,
    required this.includeMultiSig,
    Key? key,
  }) : super(key: key);

  final AddAccountOrigin origin;
  final bool includeMultiSig;

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
  }

  @override
  void dispose() {
    _bloc.onDispose();

    super.dispose();
  }

  @override
  Widget createStartPage() {
    return AccountTypeScreen(
      bloc: _bloc,
      includeMultiSig: widget.includeMultiSig,
    );
  }

  @override
  void showAccountName() {
    showPage(
      (context) => AccountNameScreen.single(
        bloc: _bloc,
        mode: FieldMode.initial,
        leadingIcon: PwIcons.close,
        message: Strings.of(context).accountNameMessage,
      ),
    );
  }

  @override
  void showCreatePassphrase() {
    showPage(
      (context) => CreatePassphraseScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showRecoverAccount() {
    showPage(
      (context) => RecoverAccountScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showAccountType() {
    showPage(
      (context) => AccountTypeScreen(
        bloc: _bloc,
        includeMultiSig: widget.includeMultiSig,
      ),
    );
  }

  @override
  void endFlow(Account? createdAccount) {
    completeFlow(createdAccount);
  }

  @override
  void showRecoveryWords() {
    showPage(
      (context) => RecoveryWordsScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showRecoveryWordsConfirm() {
    showPage(
      (context) => RecoveryWordsConfirmScreen(
        addAccountBloc: _bloc,
      ),
    );
  }

  @override
  void showBackupComplete() {
    showPage(
      (context) => BackupCompleteScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showCreatePin() {
    showPage(
      (context) => CreatePin(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showConfirmPin() {
    showPage(
      (context) => ConfirmPin(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showEnableFaceId() {
    showPage(
      (context) => EnableFaceIdScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showAccountSetupConfirmation() {
    showPage(
      (context) => AccountSetupConfirmationScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showRecoverPassphraseEntry() {
    showPage(
      (context) => RecoverPassphraseEntryScreen(
        addAccountBloc: _bloc,
      ),
    );
  }

  @override
  void showMultiSigAccountName() {
    showPage(
      (context) => AccountNameScreen.multi(
        message: Strings.of(context).accountNameMultiSigMessage,
        mode: FieldMode.initial,
        leadingIcon: PwIcons.back,
        bloc: _bloc,
      ),
    );
  }

  @override
  void showMultiSigCreateOrJoin() {
    showPage(
      (context) => MultiSigCreateOrJoinScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showMultiSigJoinLink() {
    showPage(
      (context) => MultiSigJoinLinkScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  Future<void> showMultiSigScanQrCode() async {
    final link = await showPage<String?>(
      (context) => QRCodeScanner(
        isValidCallback: (e) async => parseInviteLinkData(e) != null,
      ),
    );

    if (link != null) {
      final multiSigInvalidLink = Strings.of(context).multiSigInvalidLink;
      await _bloc.submitMultiSigJoinLink(
        multiSigInvalidLink,
        link,
        AddAccountScreen.multiSigJoinScanQrCode,
      );
    }
  }

  @override
  void showMultiSigConnect() {
    showPage(
      (context) => MultiSigConnectScreen(
        onAccount: _bloc.submitMultiSigConnect,
        enableCreate: true,
      ),
    );
  }

  @override
  void showMultiSigRecover() {
    showPage(
      (context) => MultiSigRecoverScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showMultiSigCosigners(FieldMode mode,
      [int? currentStep, int? totalSteps]) {
    showPage(
      (context) => MultiSigCountScreen.cosigners(
        title: Strings.of(context).multiSigCosignersTitle,
        message: Strings.of(context).multiSigCosignersMessage,
        description: Strings.of(context).multiSigCosignersDescription,
        bloc: _bloc,
        mode: mode,
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showMultiSigSignatures(FieldMode mode) {
    showPage(
      (context) => MultiSigCountScreen.signatures(
        title: Strings.of(context).multiSigSignaturesTitle,
        message: Strings.of(context).multiSigSignaturesMessage,
        description: Strings.of(context).multiSigSignaturesDescription,
        bloc: _bloc,
        mode: mode,
      ),
    );
  }

  @override
  void showMultiSigConfirm() {
    showPage(
      (context) => MultiSigConfirmScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showMultiSigInviteReviewFlow(
    String inviteId,
    MultiSigRemoteAccount multiSigRemoteAccount,
  ) async {
    final multiAccount = await showPage<MultiAccount?>(
      (context) => MultiSigInviteReviewFlow(
        inviteId: inviteId,
        multiSigRemoteAccount: multiSigRemoteAccount,
      ),
    );

    _bloc.submitMultiSigAccount(multiAccount);
  }
}
