// ignore_for_file: member-ordering

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }

  String displayPhone() {
    if (length == 10) {
      return '(${substring(0, 3)}) ${substring(3, 6)}-${substring(6, length)}';
    }

    return this;
  }

  double coinAmount() {
    return double.parse("${this.replaceAll(RegExp(r'[^\d\.]+'), '')}") * 100;
  }

  double amount() {
    return double.parse(this.removeNonDollarValue());
  }

  String removeNonDollarValue() {
    return this.replaceAll(RegExp(r'[^\d\.]+'), '');
  }

  String sanitizePhoneNumber() {
    return this.replaceAll(RegExp(r'[^\d]+'), '');
  }
}

// TODO: Localization

class Strings {
  // App
  static const appName = 'Provenance Wallet';

  // Biometric Strings
  static const biometric = 'Biometric';
  static const faceId = 'Face ID';
  static const touchId = 'Touch ID';
  static const face = 'Face';
  static const fingerPrint = 'Finger Print';
  static const cancel = 'Cancel';
  static const settings = 'Settings';
  static const setupBiometric = 'Please set up biometrics.';
  static const reEnableBiometric = 'Please re-enable biometrics';
  static String signInWithBiometric(String authType) =>
      'Sign in using $authType';
  static String setupWithBiometric(String authType) =>
      'Setup your account to use $authType';
  static String authenticateTransactionWithBiometric(String authType) =>
      'Authenticate the transaction using $authType.';
  static String authenticateCreditAppWithBiometric(String authType) =>
      'Authenticate the credit application using $authType.';

  // Landing Page
  static const createWallet = 'Create Wallet';
  static const recoverWallet = 'Recover Wallet';

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
  static const provenanceTitle = 'PROVENANCE\nWALLET';
  static const provenanceWalletDescription =
      'A wallet provides an easy way to manage multiple blockchain accounts.';

  // Dashboard Page
  static const loadingAssets = 'Loading Assets';
  static const sign = 'Sign';
  static const decline = 'Decline';
  static const dashboard = 'Dashboard';
  static const portfolioValue = 'Portfolio Value';
  static const send = 'Send';
  static const receive = 'Receive';
  static const walletConnect = 'WalletConnect';
  static const myAssets = 'My Assets';
  static String walletConnected(String? data) => 'Wallet connected: $data';
  static const disconnect = 'Disconnect';
  static const resetWallet = 'Reset Wallet';
  static const loadingTransactions = 'Loading Transactions';
  static const noTransactionsText =
      'When you have transactions they will appear here.';
  static const transactionDetails = "Transaction Details";

  // My Account Page
  static const myAccount = 'My Account';
  static const linkedServices = 'Linked Services';
  static const security = 'Security';
  static const pinCode = 'Pin Code';
  static const notifications = 'Notifications';
  static const general = 'General';
  static const faq = 'FAQ';
  static const sendFeedback = 'Send Feedback';
  static const contactUs = 'Contact Us';
  static const policiesAndTerms = 'Policies & Terms';

  // AddWallet Page
  static const chooseWalletType = 'Choose Wallet Type';
  static const basicWallet = 'Basic Wallet';
  static const standardSingleUserWallet = 'Standard, single-user wallet.';
  static const importRecoverWallet = 'Import/recover Wallet';
  static const importExistingWallet = 'Import existing wallet';

  // Rename Wallet Dialog
  static const walletRename = 'Wallet Rename';
  static const walletName = 'Wallet Name';
  static const required = '*required';
  static const confirm = 'Confirm';

  // Wallets Page
  static const loadingWallets = 'Loading Wallets';
  static const wallets = 'Wallets';
  static const selectedWallet = 'Selected Wallet';
  static const allWallets = 'All Wallets';

  // Wallet Item
  static const basic = 'Basic';
  static const select = 'Select';
  static const rename = 'Rename';
  static const remove = 'Remove';
  static const removeThisWallet =
      'Are you sure you want to remove this wallet?';
  static const yes = 'Yes';
  static const addressCopied = 'Address copied';

  // Account Name
  static const nameYourAccount = 'Name Your Account';
  static const accountName = 'Account Name';
  static const nameYourAccountText =
      'Name your account to easily identify it while using the Provenance Wallet.';
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
  static const setAPinCodeToUnlockYourWallet =
      "Set a pin code to unlock your wallet.";

  // EnableFaceId
  static const useFaceIdTitle = 'Use Face ID?';
  static const useYourFaceId =
      'Use your Face ID for faster, easier access to your account.';
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
      'Do not share this passphrase with anyone, as it grants full access to your account.';
  static const iAmReady = "I'm ready to begin";

  // RecoverPassphraseEntry
  static const enterRecoveryPassphrase = 'Enter recovery passphrase';
  static const recover = 'Recover';

  // RecoveryWordsConfirm
  static const verifyPassphrase = 'Verify passphrase';
  static const next = 'Next';
  static const pleaseMakeASelection = 'Please make a selection for the 4 rows.';
  static const yourSelectionsDoNotMatch =
      "Your selections don't match. Please try again.";
  static const youMustAgreeToTheWalletSeedphraseTerms =
      "Before continuing you must agree to the passphrase terms.";
  static const iAmResponsibleForMyWalletText =
      "I agree that I'm solely responsible for my wallet, and cannot recover my account the seedphrase is lost.";

  // RecoveryWords
  static const recoveryPassphrase = 'Recovery passphrase';
  static const recordTheseWordsInTheCorrectOrder =
      'Make sure to record these words in the correct order, using the corresponding numbers.';
  static const passphraseCopied = 'Passphrase Copied';

  // BackupComplete
  static const backupComplete = "Backup Complete";

  // RestoreAccountIntro
  static const recoverAccount = 'Recover Account';
  static const inTheFollowingStepsText =
      "In the following steps, you'll enter your 25-word recovery passphrase to recover your account.";

  // Session Confirmation
  static const sessionApprove = 'Approve';
  static const sessionReject = 'Reject';

  // Transaction Confirmation
  static const transaction = 'Transaction';
  static const transactionApprove = 'Approve';
  static const transactionDecline = 'Decline';

  // ValidatePin
  static const enterPin = "Enter Pin";
  static const enterPinToVerifyYourIdentity =
      'Enter pin to verify your identity.';
  static const yourPinDoesNotMatch = "Your pin doesn't match.";

  // WalletSetupConfirmation
  static const walletCreated = "WALLET CREATED";

  // TransactionsList
  static const dropDownAllAssets = "All Assets";
  static const dropDownHashAsset = "Hash";
  static const dropDownUsdAsset = "USD";
  static const dropDownUsdfAsset = "USDF";

  static const dropDownAllTransactions = "All Transactions";
  static const dropDownPurchaseTransaction = "Purchase";
  static const dropDownDepositTransaction = "Deposit";

  // TradeDetailsScreen
  static const tradeDetailsTitle = "Trade Details";
  static const tradeDetailsWallet = "Wallet";
  static const tradeDetailsTransaction = "Transaction #";
  static const tradeDetailsFromAddress = "From Address";
  static const tradeDetailsToAddress = "To Address";
  static const tradeDetailsOrderType = "Order Type";
  static const tradeDetailsAmount = "Amount";
  static const tradeDetailsPricePerUnit = "Price Per Unit";
  static const tradeDetailsTotalPurchase = "Total Purchase Price";
  static const tradeDetailsFee = "Fee";
  static const tradeDetailsTimeStamp = "Time Stamp";
  static const tradeDetailsBlock = "Block #";

  //WordSelector
  static const selectWord = 'Select word';
  static String selectWordIndex(String index) => 'Select word #${index}';
}
