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
  static const restoreWallet = 'Restore Wallet';

  // Landing Slide
  static const figureTechWallet =
      'Figure Tech Wallet is Lorem ipsum dolor sit amet, consectetur ';
  static const marketCap = 'Market Cap';
  static const validators = 'Validators';
  static const transactions = 'Transactions';
  static const avgBlockTime = 'Avg Block Time';

  // Trade Slide
  static const trade = 'Trade ';
  static const tradeHashText =
      'Trade Hash, etc lorem ipsum with confidence blah blah blah';

  // Manage Slide
  static const manageYourOwnWallet = 'Manage your own wallet';
  static const fullyControlYourWallet =
      'Fully control your wallet and crypto, and manage it independently.';

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
}
