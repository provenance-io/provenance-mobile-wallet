// ignore_for_file: member-ordering

import 'package:decimal/decimal.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String displayPhone() {
    if (length == 10) {
      return '(${substring(0, 3)}) ${substring(3, 6)}-${substring(6, length)}';
    }

    return this;
  }

  double coinAmount() {
    return double.parse(replaceAll(RegExp(r'[^\d\.]+'), '')) * 100;
  }

  double amount() {
    return double.parse(removeNonDollarValue());
  }

  String removeNonDollarValue() {
    return replaceAll(RegExp(r'[^\d\.]+'), '');
  }

  String sanitizePhoneNumber() {
    return replaceAll(RegExp(r'[^\d]+'), '');
  }

  String abbreviateAddress() {
    const left = 3;
    const right = 8;
    const dots = '...';

    return length > left + dots.length + right
        ? '${substring(0, left)}$dots${substring(length - right)}'
        : this;
  }

  String nhashToHash({int? fractionDigits}) {
    final decimal = (Decimal.parse(this) / Decimal.fromInt(10).pow(9))
        .toDecimal(scaleOnInfinitePrecision: 9);
    if (fractionDigits != null) {
      return decimal.toStringAsFixed(fractionDigits);
    }
    return decimal.toString();
  }

  String formatNumber() {
    return replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class Strings {
  // App
  static const appName = 'Provenance Blockchain Wallet';
  static const notImplementedMessage = "Not Implemented";

  // Chain
  static const chainMainNetName = 'Mainnet';
  static const chainTestNetName = 'Testnet';

  // Biometric Strings
  static const biometry = 'Biometry';
  static const faceId = 'Face ID';
  static const touchId = 'Touch ID';
  static const face = 'Face';
  static const fingerPrint = 'Finger Print';
  static const cancel = 'Cancel';
  static const settings = 'Settings';

  // Notifications
  static const String notifyServiceErrorTitle = 'Service Error';
  static const notifyNetworkErrorTitle = 'Network Disconnected';
  static const notifyServiceErrorMessage =
      'Unfortunately our services are down at the moment';
  static const notifyNetworkErrorMessage =
      'It appears as though no network is connected.';

  // Landing Page
  static const createAccount = 'Create Account';
  static const recoverAccount = 'Recover Account';
  static const lockScreenRequired =
      'Please enable the device screen lock in security settings';
  static const refresh = 'Refresh';

  // Fundamentals Slide
  static const strongFundamentals = 'STRONG\nFUNDAMENTALS';
  static const marketCap = 'Market Cap';
  static const validators = 'Validators';
  static const transactions = 'Transactions';
  static const avgBlockTime = 'Avg Block Time';
  static const fundamentalsDescription =
      "Contract execution in seconds\ninstead of weeks";

  // Customization Slide
  static const powerfulCustomization = 'POWERFUL\nCUSTOMIZATION ';
  static const customizationDescription =
      'Fully control your wallet and crypto, and manage it independently. ';

  // Landing Slide
  static const provenanceTitle = 'PROVENANCE BLOCKCHAIN\nWALLET';
  static const provenanceWalletDescription =
      'A wallet provides an easy way to manage multiple blockchain accounts.';

  // Dashboard Page
  static const dashboardConnectionRequestTitle = 'Connection Request';
  static String dashboardConnectionRequestDetails(String name) =>
      'Allow connection to $name';

  static const loadingAssets = 'Loading Assets';
  static const dashboard = 'Dashboard';
  static const portfolioValue = 'Portfolio Value';
  static const send = 'Send';
  static const receive = 'Receive';
  static const walletConnect = 'WalletConnect';
  static const myAssets = 'My Assets';
  static String walletConnected(String? data) => 'Wallet connected: $data';
  static const disconnect = 'Disconnect';
  static const loadingTransactions = 'Loading Transactions';
  static const noTransactionsText =
      'When you have transactions they will appear here.';
  static const transactionDetails = "Transaction Details";
  static const profile = "Profile";
  static const errorDisconnected = 'Disconnected';

  // QR Scanner
  static const qrScannerTitle = 'Scan QR Code';

  // Profile Page
  static const linkedServices = 'Linked Services';
  static const security = 'Security';
  static const pinCode = 'Pin Code';
  static const notifications = 'Notifications';
  static const general = 'General';
  static const aboutProvenanceBlockchain = 'About Provenance Blockchain';
  static const faq = 'FAQ';
  static const moreInformation = 'More Information';
  static const sendFeedback = 'Send Feedback';
  static const contactUs = 'Contact Us';
  static const policiesAndTerms = 'Policies & Terms';
  static const resetAccounts = 'Reset Accounts';
  static const resetAccountsAreYouSure =
      'Are you sure you wish to reset all accounts?';
  static const pinCodeUpdated = 'Pin Code Updated Successfully';
  static const successName = 'Success';
  static const profileDeveloperCategoryTitle = 'Developer';
  static const profileDeveloperHttpClients500 = 'HTTP clients return 500';
  static const profileDeveloperServiceMocks = 'Service Mocks';
  static const profileDeveloperConnectLabel = 'Connect';
  static const profileDeveloperConnectInvalidAddress = 'Invalid address';
  static const profileShowAdvancedUI = 'Show Advanced UI';
  static const profileMenuUseMainnet = 'Use Mainnet';
  static const profileMenuUseTestnet = 'Use Testnet';
  static const profileAllowCrashlitics = "Allow Crash Data Collection";

  // Service Mocks Screen
  static const developerMocksMockAssetService = "Mock Asset Service";
  static const developerMocksMockTransactionService =
      "Mock Transaction Service";
  static const developerMocksServiceUpdate = "Service Update";
  static const developerMocksRestartTheAppMessage =
      "Restart the app to allow service changes?";
  static const developerMocksRestart = "Restart";

  // Rename Account Dialog
  static const renameAccount = 'Rename Account';
  static const renameAccountDescription =
      'Please enter the new name you would like to call your account.';
  static const renameAccountAccountName = 'Account Name';
  static const required = '*required';
  static const confirm = 'Confirm';

  // Accounts Page
  static const accounts = 'Accounts';
  static String numAssets(int numAssets) =>
      "$numAssets Asset${numAssets != 1 ? "s" : ""}";

  // Account Item
  static const select = 'Select';
  static const rename = 'Rename';
  static const remove = 'Remove';
  static const removeThisAccount =
      'Are you sure you want to remove this account?';
  static const yes = 'Yes';
  static const copyAccountAddress = 'Copy Account Address';
  static const addressCopied = 'Address copied';

  // Account Name
  static const nameYourAccount = 'Name Your Account';
  static const accountName = 'Account Name';
  static const nameYourAccountText =
      'Name your account to easily identify it while using the Provenance Blockchain Wallet.';
  static const infoIsStoredLocallyText =
      "These names are stored locally, and can only be seen by you.";
  static const continueName = 'Continue';

  // Confirm Pin
  static const verifyPinCode = 'Verify Pin Code';
  static const confirmYourPinCodeReminder =
      "Confirm your pin code. Make sure you remember it as you cannot recover it if you lose it.";
  static const yourPinDoesNotMatchPleaseTryAgain =
      "Your pin doesn't match. Please try again or go back and re-enter your pin.";

  // CreatePin
  static const setPinCode = 'Set Pin Code';
  static const setAPinCodeToUnlockYourAccount =
      "Set a pin code to unlock your account.";

  // EnableFaceId
  static const useFaceIdTitle = 'Use Face ID?';
  static const useYourFaceId =
      'Use your Face ID for faster, easier\naccess to your account.';
  static const useTouchIdTitle = 'Use Touch ID?';
  static const useYourFingerPrint =
      "Use your Touch ID for faster,\neasier access to your account.";
  static const useBiometryTitle = 'Biometry';
  static const useBiometryMessage =
      'Enable Face ID or Touch ID\non your device for faster, easier\naccess to your account.';
  static const enable = 'Enable';
  static const pleaseWait = 'Please Wait';
  static const skipForNow = 'Skip for now';

  // PrepareRecoveryPhraseIntro
  static const createPassphrase = "Create Passphrase";
  static const savePassphrase = "SAVE PASSPHRASE";
  static const prepareToWriteDownYourRecoveryPhrase =
      'Prepare to write down your recovery phrase.';
  static const theOnlyWayToRecoverYourAccount =
      'The only way to recover your account is with this recovery passphrase.';
  static const warningDoNotShare =
      'Do not share this passphrase with anyone as it grants full access to your account.';
  static const iAmReady = "I'm ready to begin";

  // RecoverPassphraseEntry
  static const enterRecoveryPassphrase = 'Enter recovery passphrase';
  static const recover = 'Recover';
  static String recoverPassphraseNetwork(String name) {
    return 'Network: $name';
  }

  static const invalidWord = "Invalid word";

  static String recoverPassphraseWord(int number) {
    return 'Word $number';
  }

  // RecoveryWordsConfirm
  static const verifyPassphrase = 'Verify Passphrase';
  static const next = 'Next';
  static const pleaseMakeASelection = 'Please make a selection for the 4 rows.';
  static const yourSelectionsDoNotMatch =
      "Your selections don't match. Please try again.";
  static const youMustAgreeToThePassphraseTerms =
      "Before continuing you must agree to the passphrase terms.";
  static const iAmResponsibleForMyAccountText =
      "I agree that I am solely responsible for my account and cannot recover it if the passphrase is lost.";

  // RecoveryWords
  static const recoveryPassphrase = 'Recovery Passphrase';
  static const recordTheseWordsInTheCorrectOrder =
      'Make sure to record these words in the correct order using the corresponding numbers.';
  static const passphraseCopied = 'Passphrase Copied';
  static const copyPassphrase = 'Copy Passphrase';

  // BackupComplete
  static const backupComplete = "Backup Complete";

  // RestoreAccountIntro
  static const inTheFollowingStepsText =
      "In the following steps, you'll enter your 24-word recovery passphrase to recover your account.";

  // Session Confirmation
  static const sessionApprove = 'Approve';
  static const sessionReject = 'Reject';

  // Transaction
  static String transactionErrorUnsupportedMessage(String messageName) =>
      'Unsupported message type: $messageName';
  static const transactionSuccessTitle = 'Success';
  static const transactionErrorTitle = 'Error';

  // Transaction Confirmation
  static const confirmSignTitle = 'Signature';
  static const confirmTransactionTitle = 'Transaction';
  static const transactionApprove = 'Approve';
  static const transactionDecline = 'Decline';
  static const transactionBackToDashboard = 'Back to dashboard';
  static const transactionDataTitle = 'Data';
  static const transactionDataButton = 'Data';
  static const transactionDenomHash = 'Hash';
  static const transactionFieldPlatform = 'Platform';
  static const transactionFieldFee = 'Gas Fee';
  static const transactionFieldMessage = 'Message';
  static const transactionFieldMessageType = 'Msg. Type';
  static const transactionFieldTrue = 'Yes';
  static const transactionFieldFalse = 'No';

  // ValidatePin
  static const enterPin = "Enter Pin";
  static const enterPinToVerifyYourIdentity =
      'Enter pin to verify your identity.';
  static const yourPinDoesNotMatch = "Your pin doesn't match.";

  // AccountSetupConfirmation
  static const accountCreated = "ACCOUNT CREATED";

  // TransactionsList
  static const dropDownAllMessageTypes = "All Message Types";
  static const dropDownAllStatuses = "All Statuses";
  static const buy = "Buy";
  static const sell = "Sell";

  // TradeDetailsScreen
  static const tradeDetailsTitle = "Trade Details";
  static const tradeDetailsAccount = "Account";
  static const tradeDetailsTransaction = "Transaction Hash";
  static const tradeDetailsResult = "Result";
  static const tradeDetailsMessageType = "Message Type";
  static const tradeDetailsFee = "Fee";
  static const tradeDetailsTimeStamp = "Time";
  static const tradeDetailsBlock = "Block Height";
  static const tradeDetailsAssetName = "Asset Name";

  //WordSelector
  static const selectWord = 'select word';
  static String selectWordIndex(String index) => 'select word #$index';

  // SendScreen
  static const sendTitle = "Send";
  static const noRecentSends = "No recent sends";
  static const viewAllLabel = "View All";
  static const nextButtonLabel = "Next";
  static const sendPageRecentAddress = "Recent addresses";
  static const sendPageSelectAsset = "Select Asset";
  static const sendPageScanQrCode = "paste or scan QR code";
  static const sendPageSendToAddressLabel = "Send to Address";

  // SendAmountScreen
  static const sendAmountTitle = "Send Amount";
  static const sendAmountHint = "Enter an amount";
  static const sendAmountNextButton = "Next";
  static const sendAmountNoteHint = "Note";
  static const sendAmountAvailable = "available";
  static const sendAmountNoteSuffix = "Click to add a note";
  static const sendAmountLoadingFeeEstimate = "Acquiring Estimate";
  static const sendAmountTransactionLabel = "Transaction";
  static const sendAmountErrorTooManyDecimalPlaces = "too many decimal places";
  static const sendAmountErrorInsufficient = "Insufficient";
  static const sendAmountErrorInvalidAmount = "is an invalid amount";
  static const sendAmountErrorGasEstimateNotReady =
      "The estimated fee is not ready";

  // SendReviewScreen
  static const sendReviewTitle = "Send Review";
  static const sendReviewConfirmYourInfo = "Confirm your information";
  static const sendReviewSendButtonTitle = "Send";
  static const sendReviewSendPleaseReview =
      "Please review the details below to make sure everything is correct";
  static const sendReviewSending = "Sending";
  static const sendReviewTransactionFee = "Transaction Fee";
  static const sendReviewTotal = "Total";

  // Error Dialog
  static const unknownErrorTitle = 'UNKNOWN ERROR';
  static const somethingWentWrong = 'Something went wrong.';
  static const okay = "Okay";
  static const serviceErrorTitle = 'SERVICE ERROR';
  static const theSystemIsDown =
      'Unfortunately our services are down at the moment. Please try again later.';

  // ConnectionDetails
  static const connectionDetails = "Connection Details";
  static const unknown = "Unknown";
  static const platform = "Platform";
  static const url = "URL";

  static const receiveTitle = "Receive";
  static const receiveMessage =
      "Show this QR code or share account address to receive asset";
  static const receiveAccountAddressTitle = "Account Address";
  static const receiveAccountAddressCopiedMessage =
      "Your address was copied to the clipboard";

  // AssetChartScreen
  static const statistics = "Statistics";
  static const dayVolume = "Day Volume";
  static const currentPrice = "Current Price";
  static const dayHigh = "Day High";
  static const dayLow = "Day Low";
  static const recentTransactions = "Recent Transactions";
  static const allTransactions = "All Transactions";
  static const assetChartNotAvailable = "Not Available";
  static const assetChartNoDataAvailable = "No data available.";

  // SendSuccessScreen
  static const sendSuccessTransferDetailsBelow =
      "Your transfer details are below";
  static const sendDate = "Date";
  static const sendTo = "To";
  static const sendDone = "Done";

  // PushNotification
  static const channelTitle = "High Importance Notifications";
  static const channelDescription =
      "This channel is used for important notifications.";

  // Cipher errors
  static const cipherErrorTitle = 'Cipher Error';
  static const cipherAccessError = 'An access error occurred.';
  static const cipherAccountKeyNotFoundError = 'Account key not found.';
  static const cipherAddSecItemError = 'Failed to add security item.';
  static const cipherDataPersistenceError = 'Data persistence failed.';
  static const cipherInvalidArgumentError = 'Invalid argument.';
  static const cipherPublicKeyError = 'Public key error.';
  static const cipherSecKeyNotFoundError = 'Security item not found.';
  static const cipherUnknownError = 'Unknown error.';
  static const cipherUpgradeError = 'An error occured during while upgrading.';
  static const cipherUnsupportedAlgorithmError = 'Unsupported algorithm.';

  // Explorer Screen
  static const staking = "Staking";
  static const proposals = "Proposals";

  // Staking Tab
  static const dropDownDelegateHeader = "My Validator Type:";
  static const dropDownDelegate = "Delegate";
  static const dropDownRedelegate = "Redelegate";
  static const dropDownUndelegate = "Undelegate";
  static const dropDownStateHeader = "Validator Status:";
  static const dropDownActive = "Active";
  static const dropDownCandidate = "Candidate";
  static const dropDownJailed = "Jailed";
  static String endTimeFormatted(String formattedTime) =>
      "Ended: $formattedTime";
  static String displayDenomFormatted(String displayDenom) =>
      "$displayDenom delegated";
}
