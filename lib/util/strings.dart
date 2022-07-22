// ignore_for_file: member-ordering

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String formatNumber() {
    var sections = split('.');
    sections[0] = sections[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return sections.join('.');
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
  static const cancel = 'Cancel';

  // Notifications
  static const String notifyServiceErrorTitle = 'Service Error';
  static const notifyNetworkErrorTitle = 'Network Disconnected';
  static const notifyServiceErrorMessage =
      'Unfortunately our services are down at the moment';
  static const notifyNetworkErrorMessage =
      'It appears as though no network is connected.';

  // Landing Page
  static const addAccount = 'Add Account';
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

  static const dashboard = 'Dashboard';
  static const portfolioValue = 'Portfolio Value';
  static const send = 'Send';
  static const receive = 'Receive';
  static const myAssets = 'My Assets';
  static const disconnect = 'Disconnect';
  static const transactionDetails = "Transaction Details";
  static const globalSettings = "Global Settings";
  static const errorDisconnected = 'Disconnected';
  static const viewMore = "View More";
  static const staking = "Staking";
  static const governanceProposals = "Governance Proposals";

  // QR Scanner
  static const qrScannerTitle = 'Scan QR Code';

  // Settings Page
  static const security = 'Security';
  static const pinCode = 'Pin Code';
  static const general = 'General';
  static const aboutProvenanceBlockchain = 'About Provenance Blockchain';
  static const moreInformation = 'More Information';
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
  static const profileDeveloperEnableMultiSig = 'Enable Multi-Sig';
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
  static const required = 'Required';
  static const starRequired = '*Required';
  static const confirm = 'Confirm';

  // Accounts Page
  static const accounts = 'Accounts';
  static const accountKindBasic = 'Basic';
  static const accountKindMulti = 'Multi-sig';
  static const selectedAccountLabel = 'Selected Account';
  static const accountStatusPending = 'Pending';
  static const accountMenuItemViewInvite = 'View Invitation Details';
  static String numAssets(int numAssets) =>
      "$numAssets Asset${numAssets != 1 ? "s" : ""}";
  static String accountLinkedTo(String name) => 'Linked to ‘$name’';

  // Account Item
  static const select = 'Select';
  static const rename = 'Rename';
  static const remove = 'Remove';
  static const removeThisAccount =
      'Are you sure you want to remove this account?';
  static const yes = 'Yes';
  static const copyAccountAddress = 'Copy Account Address';
  static const addressCopied = 'Address copied';

  // Account Type
  static const accountTypeTitle = 'Choose Account Type';
  static const accountTypeOptionBasicName = 'Basic Account';
  static const accountTypeOptionBasicDesc = 'Standard, single-user account';
  static const accountTypeOptionImportName = 'Import/Recover Account';
  static const accountTypeOptionImportDesc = 'Import existing account';
  static const accountTypeOptionMultiName = 'Multi-Sig Account';
  static const accountTypeOptionMultiDesc =
      'Account shared by two or more users';

  // Multi-Sig
  static const multiSigNextButton = 'Next';
  static const multiSigSaveButton = 'Save';

  // Multi-Sig Create or Join
  static const accountTypeMultiSigTitle = 'Multi-Signature Account';
  static const accountTypeMultiSigDesc =
      'A multi-signature account requires two or more private keys to sign and send a transaction.\n\nA multi-signature account helps to get rid of the security concerns that come with a single private key mechanism, and reduces the dependency on one person.';
  static const accountTypeMultiSigCreateName = 'Create New';
  static const accountTypeMultiSigCreateDesc =
      'Account shared by two or more users';
  static const accountTypeMultiSigJoinName = 'Join Multi-Signature Account';
  static const accountTypeMultiSigJoinDesc = 'Requires account invitation';
  static const accountTypeMultiSigJoinLink = 'Have an invitation link?';
  static const accountTypeMultiSigRecoverName = 'Recover';
  static const accountTypeMultiSigRecoverDesc =
      'Using existing linked basic account';

  // Multi-Sig Invite Review Landing

  static String multiSigInviteReviewLandingDesc(String accountName) =>
      'You’re invited to join the "$accountName" Multi-Sig Wallet';
  static const multiSigInviteReviewLandingLearnMoreButton = 'Learn More';

  // Multi-Sig Invite Review Invitation Details
  static const multiSigInviteReviewDetailsTitle = 'Review Invitation';
  static const multiSigInviteReviewDetailsDesc =
      'Review the multi-sig account information.';
  static const multiSigInviteReviewDetailsChooseAccountButton =
      'Choose Individual Account';
  static const multiSigInviteReviewDetailsMaybeLaterButton = 'Maybe Later';
  static const multiSigInviteReviewDetailsDeclineButton = 'Decline Invitation';

  // Multi-Sig Invite Review Create or Link
  static const multiSigInviteReviewCreateOrLinkTitle =
      'Choose Individual Account';
  static const multiSigInviteReviewCreateOrLinkCreate = 'Create New Account';
  static const multiSigInviteReviewCreateOrLinkCreateDesc =
      'Create a passphrase and use this account to join the multi-sig account';
  static const multiSigInviteReviewCreateOrLinkLinkExisting =
      'Link Existing Account';
  static const multiSigInviteReviewCreateOrLinkLinkExistingDesc =
      'Select an account to join this multi-sig account';

  // Multi-Sig Join Link
  static const multiSigJoinLinkTitle = 'Multi-Signature Account';
  static const multiSigJoinLinkMessage =
      'Paste invitation code address you’ve received as an invitation';
  static const multiSigJoinLinkFieldLabel = 'Enter Invitation Link';
  static const multiSigInvalidLink = 'Invalid link, please try again.';

  // Multi-Sig Connect
  static const multiSigConnectTitle = 'Connect to Individual Account';
  static const multiSigConnectDesc =
      "Select an account to link with the multi-sig account.";
  static const multiSigConnectSelectionLabel = 'Select Account';
  static const multiSigConnectCreateButton = 'Create New Account';

  // Multi-Sig Cosigners
  static const multiSigCosignersTitle = 'Set Number of Co-Signers';
  static const multiSigCosignersMessage = 'Set the number of co-signers';
  static const multiSigCosignersDescription =
      'All co-signers will have access to this wallet. You may have a maximum of 10 co-signers including yourself.';

  // Multi-Sig Signatures
  static const multiSigSignaturesTitle = 'Set Number of Signatures';
  static const multiSigSignaturesMessage =
      'Set the minimum signatures required';
  static const multiSigSignaturesDescription =
      'This will be the number of signatures required to authorize a transaction.';

  // Multi-Sig Confirm
  static const multiSigConfirmTitle = 'Confirm Account';
  static const multiSigConfirmMessage =
      'Please confirm the information below. You cannot alter the information after account creation is complete.';
  static const multiSigConfirmAccountNameLabel = 'Account Name';
  static const multiSigConfirmCosignersLabel = 'Total number of co-signers';
  static const multiSigConfirmSignaturesLabel = 'Signatures required';

  // Multi-Sig Creation Status
  static const multiSigCreationStatusTitle = 'Multi-Sig Account Invitation';
  static const multiSigCreationStatusMessage = "Here’s how it works:";
  static const multiSigCreationStatusDescription =
      'Share the QR code or invitation link with the co-signers joining this account. Each co-signer has to create their own recovery phrase once everyone accepts invitation.\n\nTo recover funds stored in a multi-sig account, you need the recovery phrase from each co-signer.';
  static const multiSigCreationStatusListHeading = 'Wallet Creation Status:';
  static const multiSigCreationStatusGetStatusError = 'Failed to get status';

  // Multi-Sig Invite
  static const multiSigInviteCosignerSelf = 'Self';
  static const multiSigInviteCosignerPrefix = 'Co-signer #';
  static const multiSigInviteTitlePrefix = 'For Co-signer #';
  static const multiSigInviteDescription =
      'Invite your co-signer to scan the QR code below or share their invitation link';
  static const multiSigInviteShareButtonLabel = 'Share Invitation';
  static const multiSigInviteMessagePrefix = 'Your message:\n';
  static const multiSigInviteSubject =
      'Provenance Blockchain Multi-sig Account Invitation';
  static const multiSigInviteMessage =
      '“You’re invited to join my Provenance Blockchain Multi-sig Account by clicking the link below.”';

  // Multi-Sig Recover
  static const multiSigRecoverLoadError = 'An error occured';
  static const multiSigRecoverTitle = 'Recover Account';

  // Account Name
  static const nameYourAccount = 'Name Your Account';
  static const accountName = 'Account Name';
  static const accountNameMessage =
      'Name your account to easily identify it while using the Provenance Blockchain Wallet.\n\nThese names are stored locally, and can only be seen by you.';
  static const accountNameMultiSigMessage =
      'Name your account to easily identify it while using the Provenance Blockchain Wallet.\n\nThis name will be shared with co-signers.';
  static const continueName = 'Continue';

  // Confirm Pin
  static const verifyPinCode = 'Verify Pin Code';
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

  // RecoverPassphraseEntry
  static const enterRecoveryPassphrase = 'Enter recovery passphrase';
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

  // TradeDetailsScreen
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

  // NotificationList
  static const notificationListEditLabel = 'Edit';
  static const notificationListStatusLabel = 'Status Update';

  // ActionList
  static const actionListSelected = "Selected";
  static const actionListBasicAccount = "Basic";
  static const actionListMultiSigAccount = "Multi-Sig";

  static const actionListAction = "Action";
  static const actionListActions = "Actions";

  // ActionListScreen strings
  static const actionListActionsCellTitle = 'Actions';
  static const actionListNotificationsCellTitle = 'Notifications';

  static const actionListLabelApproveSession = 'Approve Session';
  static const actionListLabelSignatureRequested = 'Signature Requested';
  static const actionListLabelTransactionRequested = 'Transaction Requested';
  static const actionListLabelUnknown = 'Unknown';

  static const actionListSubLabelActionRequired = 'Action Required';

  static const deleteConfirmationDeleteTitle = 'Delete';
  static const deleteConfirmationTitle = 'Confirm Delete';
  static const deleteConfirmationMessage = 'Do you want to delete these Items';
  // Staking Tab
  static const stakingTabMyDelegations = "My Delegations";
  static const stakingTabStakingDefined =
      "Staking is a process that involves committing your assets to support Provenance's network and to confirm transactions.";
  static const stakingTabAvailableToSelect = "Available to Select";
  static const stakingTabSortBy = "Sort by";
  static const dropDownVotingPower = "Voting Power";
  static const dropDownAlphabetically = "Name";
  static String displayDenomFormatted(String displayDenom) =>
      "$displayDenom delegated";
  static String displayDelegatorsWithCommission(
          int delegators, String commission) =>
      "$delegators delegators • $commission commission";

  // Staking Details
  static const stakingDetailsDelegation = "Delegation";
  static const stakingDetailsDelegationStatus = "Delegation Status";
  static const stakingDetailsDelegating = "Delegating";
  static const stakingDetailsStatus = "Status";
  static const stakingDetailsCommissionInformation = "Commission Information";
  static const stakingDetailsAdditionalDetails = "Additional Details";
  static const stakingDetailsButtonDelegate = "Delegate";
  static const stakingDetailsAddresses = "Addresses";
  static const stakingDetailsOperatorAddress = "Operator Address";
  static const stakingDetailsOperatorAddressCopied = "Operator Address Copied";
  static const stakingDetailsOwnerAddress = "Owner Address";
  static const stakingDetailsOwnerAddressCopied = "Owner Address Copied";
  static const stakingDetailsWithdrawAddress = "Withdraw Address";
  static const stakingDetailsWithdrawAddressCopied = "Withdraw Address Copied";
  static const stakingDetailsUnbondingHeight = "Unbonding Height";
  static const stakingDetailsVotingPower = "Voting Power";
  static const stakingDetailsUptime = "Uptime";
  static const stakingDetailsMissedBlocks = "Missed Blocks";
  static const stakingDetailsBondHeight = "Bond Height";
  static const stakingDetailsConsensusPubkey = "Consensus Pubkey";
  static const stakingDetailsConsensusPubkeyCopied = "Consensus Pubkey Copied";
  static const stakingDetailsJailedUntil = "Jailed Until";
  static const stakingDetailsCommissionRate = "Commission Rate";
  static const stakingDetailsDelegators = "Delegators";
  static const stakingDetailsRewards = "Rewards";
  static const stakingDetailsMaxChangeRate = "Max Change Rate";
  static const stakingDetailsBonded = "Bonded";
  static const stakingDetailsTotalShares = "Total Shares";
  static const stakingDetailsCommissionRateRange = "Commission Rate Range";
  static const stakingDetailsValidatorTransactions = "Validator Transactions";
  static const stakingDetailsViewLess = "View Less";

  // Staking Management
  static const stakingManagementMyDelegation = "My Delegation";
  static const stakingManagementNoHash = "-- HASH";

  // Staking Confirm
  static const stakingConfirmData = "Data";
  static const stakingConfirmGasAdjustment = "Gas Adjustment";
  static const stakingConfirmDefault = "(Default)";
  static const stakingConfirmRewardsAvailable = "Rewards Available";
  static const starPositiveNumber = '*Positive number';

  // Staking delegate
  static const stakingDelegateWarningAccountLockTitle =
      "Warning: Account will lock";
  static const stakingDelegateWarningAccountLockMessage =
      "In order to undelegate funds back into this account, the account will need to be able to pay the required fees. Delegating the specified amount of funds from this account will result in it being locked until another account sends it funds.";
  static const stakingDelegateWarningFundsLockTitle =
      "Staking will lock your funds for 21+ days";
  static const stakingDelegateWarningFundsLockMessage =
      "You will need to undelegate in order for your staked assets to be liquid again. This process will take 21 days to complete.";
  static const stakingDelegateAvailableBalance = "Available HASH Balance";
  static const stakingDelegateAmountToDelegate = "Amount to Delegate*";
  static const stakingDelegateCurrentDelegation = "Current Delegation";
  static const stakingDelegateDetails = "Details";
  static const stakingDelegateEnterAmountToDelegate =
      "Enter Amount of HASH to delegate";

  // Staking Redelegate
  static const stakingRedelegateRedelegate = "Redelegate";
  static const stakingRedelegateAvailableForRedelegation =
      "Available for Redelegation";
  static const stakingRedelegateRedelegating = "Redelegating";
  static const stakingRedelegateFrom = "From";
  static const stakingRedelegateTo = "To";
  static const stakingRedelegateValidatorNotSelected =
      "Validator has not been selected yet";
  static const stakingDelegateAmountToRedelegate = "Amount to Redelegate*";
  static const stakingRedelegateEnterAmount =
      "Enter Amount of HASH to redelegate";

  // Staking Undelegate
  static const stakingUndelegateUndelegate = "Undelegate";
  static const stakingUndelegateUndelegating = "Undelegating";
  static const stakingUndelegateUndelegationDetails = "Undelegation Details";
  static const stakingUndelegateWarningUnbondingPeriodTitle =
      "Once the unbonding period begins you will:";
  static const stakingUndelegateWarningUnbondingPeriodMessage =
      " • not receive staking reward\n • not be able to cancel the unbonding\n • need to wait 21 days for the amount to be liquid";
  static const stakingUndelegateWarningSwitchValidators =
      "Trying to switch validators? Instantly stake your assets to another validator by tapping here.";
  static const stakingUndelegateAvailableForUndelegation =
      "Available for Undelegation";
  static const stakingUndelegateAmountToUndelegate = "Amount to Undelegate*";
  static const stakingUndelegateEnterAmount =
      "Enter Amount of HASH to undelegate";

  // Staking Delegation Bloc
  static const stakingDelegationBlocBack = "Back";
  static const stakingDelegationBlocClaimRewards = "Claim Rewards";
  static const stakingConfirmClaimRewardsDetails = "Claim Rewards Details";

  // Staking Success Screen
  static const stakingSuccessSuccess = "SUCCESS";
  static String stakingSuccessSuccessful(String delegationType) =>
      '$delegationType successful';
  static const stakingSuccessBackToDashboard = "Back to Dashboard";

  static String stakingConfirmHashAmount(String amount) => '$amount HASH';

  // Proposals Screen
  static const proposalsScreenLegend = "Legend";
  static const proposalsScreenMyStatus = "My Status:";
  static String proposalsScreenVoted(String formattedVote) =>
      "Voted $formattedVote";

  // Proposal Details Screen
  static String proposalDetailsTitle(int proposalId) =>
      "Governance Proposal $proposalId";
  static const proposalDetailsProposalInformation = "Proposal Information";
  static const proposalDetailsId = "ID#";
  static const proposalDetailsTitleString = "Title";
  static const proposalDetailsStatus = "Global Status";
  static const proposalDetailsMyStatus = "My Status";
  static const proposalDetailsDescription = "Description";
  static const proposalDetailsProposalTiming = "Proposal Timing";
  static const proposalDetailsSubmitTime = "Submit Time";
  static const proposalDetailsDepositEndTime = "Deposit End Time";
  static const proposalDetailsVotingStartTime = "Voting Start Time";
  static const proposalDetailsVotingEndTime = "Voting End Time";
  static const proposalDetailsDeposits = "Deposits";
  static String proposalDetailsDepositsHash(
          String deposited, String depositPercentage) =>
      "$deposited HASH ($depositPercentage)";
  static const proposalDetailsThresholdDetails = "Threshold Details";
  static const proposalDetailsQuorumThreshold = "Quorum Threshold";
  static const proposalDetailsPassThreshold = "Pass Threshold";
  static const proposalDetailsVetoThreshold = "Veto Threshold";
  static const proposalDetailsPercentVoted = "Percent Voted";
  static const proposalDetailsTotalVotes = "Total Votes";
  static const proposalDetailsYes = "Yes";
  static const proposalDetailsNo = "No";
  static const proposalDetailsNoWithVeto = "No w/Veto";
  static const proposalDetailsAbstain = "Abstain";
  static const proposalDetailsProposalVoting = "Proposal Voting";
  static const proposalDetailsNeededDeposit = "Needed Deposit";
  static String proposalDetailsHashNeeded(double needed) => "$needed HASH";

  // Weighted Vote Screen
  static const proposalWeightedVote = "Weighted Vote";
  static const proposalWeightedVoteVotingStatus = "Voting Status";
  static const proposalWeightedVoteVoteYes = "Vote Yes";
  static const proposalWeightedVoteVoteNo = "Vote No";
  static const proposalWeightedVoteVoteNoWithVeto = "Vote No w/Veto";
  static const proposalWeightedVoteVoteAbstain = "Vote Abstain";

  // Proposal Vote Confirm Screen
  static const proposalVoteConfirmConfirmVote = "Confirm Vote";
  static const proposalVoteConfirmVotingDetails = "Voting Details";
  static const proposalVoteConfirmProposalId = "Proposal ID#";
  static const proposalVoteConfirmTitle = "Title";
  static const proposalVoteConfirmProposerAddress = "Proposer Address";
  static const proposalVoteConfirmVoterAddress = "Voter Address";
  static const proposalVoteConfirmVoteOption = "Vote Option:";
  static const proposalVoteConfirmVote = "Vote";

  // Proposal Vote Confirm Screen
  static const proposalWeightedVoteConfirmWeightedVote =
      "Confirm Weighted Vote";
  static const proposalWeightedVoteProposalId = "Proposal ID#";

  // Proposal Vote Success
  static const proposalVoteSuccessSuccess = "SUCCESS";
  static const proposalVoteSuccessVoteSuccessful = "Vote Successful";
  static const proposalVoteSuccessBackToDashboard = "Back To Dashboard";

  // Confirm Undelegate Screen
  static const stakingConfirmUndelegationDetails = "Undelegation Details";
  static const stakingConfirmAmountToUndelegate = "Amount to Undelegate";
  static const stakingConfirmNewTotalDelegation = "New Total Delegation";

  // Confirm Redelegate Screen
  static const stakingConfirmRedelegationDetails = "Redelegation Details";
  static const stakingConfirmAmountToRedelegate = "Amount to Redelegate";

  // Confirm Delegate Screen
  static const stakingConfirmDelegating = "Delegating";
  static const stakingConfirmDelegationDetails = "Delegation Details";
  static const stakingConfirmAmountToDelegate = "Amount to Delegate";
}
