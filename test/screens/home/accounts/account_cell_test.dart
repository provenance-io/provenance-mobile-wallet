import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/home/accounts/account_cell.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/rename_account_dialog.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';

import './account_cell_test.mocks.dart';
import '../../../dashboard/home_mocks.dart';
import '../../../test_helpers.dart';

@GenerateMocks([MultiSigClient, AccountService])
void main() {
  const pubKeyHex1 = "AtqS7MRO7zKZ4Azfj0do1bYGv4JC/1J35vB6rdk1JXo3";
  const pubKeyHex2 = "A20rKxFRxuXvhRpOZRz3jCzkO91HMDiCDyTHgVevYnzJ";

  final pubKey1 = PublicKey.fromCompressPublicHex(
      Base64Decoder().convert(pubKeyHex1), Coin.testNet);

  final pubKey2 = PublicKey.fromCompressPublicHex(
      Base64Decoder().convert(pubKeyHex2), Coin.testNet);

  final amino1 = AminoPubKey(
      publicKeys: [pubKey1, pubKey2], coin: Coin.testNet, threshold: 2);

  final account = BasicAccount(
    id: "BasicAccountId",
    name: "BasicAccountName",
    publicKey: pubKey1,
  );

  final multiAccount = MultiAccount(
    id: "BasicAccountId",
    name: "BasicAccountName",
    publicKey: amino1,
    cosignerCount: 2,
    inviteIds: [],
    linkedAccount: account,
    remoteId: "test",
    signaturesRequired: 2,
  );

  String? copiedString;

  AppLocalizations? strings;

  late StreamController<Account> _accountStream;

  setUp(() {
    _accountStream = StreamController<Account>();
  });

  tearDown(() {
    _accountStream.close();
  });

  Future<void> _build(
      WidgetTester tester, Account account, bool isSelected) async {
    await tester.pumpWidget(ProvenanceTestAppRig(
      child: AccountCell(
        account: account,
        isSelected: isSelected,
        isRemovable: true,
        onRename: ({
          required String id,
          required String name,
        }) =>
            Future.value(),
        onRemove: ({
          required String id,
        }) =>
            Future.value(),
      ),
    ));

    strings = await AppLocalizations.delegate
        .load(AppLocalizations.supportedLocales.first);

    copiedString = null;
    SystemChannels.platform.setMockMethodCallHandler((call) {
      if (call.method == "Clipboard.setData") {
        copiedString = call.arguments["text"] as String?;
      }
      return Future.value();
    });
  }

  Future<Finder> _buildAndShowMenu(WidgetTester tester, Account account) async {
    await _build(tester, account, true);

    final accountContainerFind = find.byType(AccountContainer);
    final accountContainer =
        tester.widget<AccountContainer>(accountContainerFind);

    accountContainer.onShowMenu!();

    await tester.pumpAndSettle(Duration(milliseconds: 600));
    return find.byKey(AccountCell.accountCellMenuKey);
  }

  group("BasicAccount", () {
    testWidgets("background color is set by isSelected", (tester) async {
      final rootContainerFind =
          find.byKey(AccountCell.accountCellBackgroundKey);

      await _build(tester, account, true);
      final theme = tester.widget<Theme>(find.byType(Theme));

      var rootContainer = tester.widget<Container>(rootContainerFind);
      expect(rootContainer.color, theme.data.colorScheme.secondary650);

      await _build(tester, account, false);

      rootContainer = tester.widget<Container>(rootContainerFind);
      expect(rootContainer.color, theme.data.colorScheme.neutral700);
    });

    testWidgets("only AccountContainer is present", (tester) async {
      await _build(tester, account, true);
      expect(find.byType(AccountContainer), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
      expect(find.byType(LinkedAccount), findsNothing);
    });

    testWidgets("AccountContainer contents match the account details",
        (tester) async {
      await _build(tester, account, true);
      final accountContainerFind = find.byType(AccountContainer);
      final accountContainer =
          tester.widget<AccountContainer>(accountContainerFind);
      expect(accountContainer.rows.length, 3);
      expect(accountContainer.isSelected, true);
      expect(accountContainer.onShowMenu, isNotNull);

      expect(accountContainer.rows[0] is AccountTitleRow, true);
      expect(accountContainer.rows[1] is AccountDescriptionRow, true);
      expect(accountContainer.rows[2] is AccountNetworkRow, true);
    });

    testWidgets("Show menu options", (tester) async {
      await _build(tester, account, true);

      final accountContainerFind = find.byType(AccountContainer);
      final accountContainer =
          tester.widget<AccountContainer>(accountContainerFind);

      accountContainer.onShowMenu!();
      await tester.pumpAndSettle(Duration(milliseconds: 600));
      final menuFind = find.byKey(AccountCell.accountCellMenuKey);
      final menuItemsFind =
          find.descendant(of: menuFind, matching: find.byType(PwGreyButton));

      final menuItems = tester.widgetList<PwGreyButton>(menuItemsFind).toList();
      expect(menuItems[0].text, strings!.rename);
      expect(menuItems[1].text, strings!.copyAccountAddress);
      expect(menuItems[2].text, strings!.remove);
    });

    group("Copy menu item clicked", () {
      testWidgets("Snackbar displays properly", (tester) async {
        final menuFind = await _buildAndShowMenu(tester, account);

        await tester
            .tap(find.descendant(
                of: menuFind, matching: find.text(strings!.copyAccountAddress)))
            .then((_) => tester.pump(Duration(milliseconds: 600)));

        expect(copiedString, account.address);

        final snackBarFind = find.byType(SnackBar, skipOffstage: false);
        expect(snackBarFind, findsOneWidget);

        expect(
            find.descendant(
                of: snackBarFind, matching: find.text(strings!.addressCopied)),
            findsOneWidget);
      });
    });

    group("Rename menu item clicked", () {
      testWidgets("Rename dialog appears when the menu is clicked",
          (tester) async {
        final menuFind = await _buildAndShowMenu(tester, account);

        await tester
            .tap(find.descendant(
                of: menuFind, matching: find.text(strings!.rename)))
            .then((_) => tester.pump(Duration(milliseconds: 600)));

        final dialogFind = find.byType(RenameAccountDialog);
        expect(dialogFind, findsOneWidget);

        final dialog = tester.widget<RenameAccountDialog>(dialogFind);
        expect(dialog.currentName, account.name);
      });
    });
  });

  group("MuliSigAccount", () {
    final aminoPublicKey = AminoPubKey(
        threshold: 2, publicKeys: [pubKey1, pubKey2], coin: Coin.testNet);

    final multiSigAccount = MultiAccount(
        id: "Id1",
        name: "Multisig Account",
        inviteIds: ["A", "B"],
        remoteId: "RemoteId",
        signaturesRequired: 2,
        cosignerCount: 2,
        linkedAccount: account,
        publicKey: aminoPublicKey);

    testWidgets("background color is set by isSelected", (tester) async {
      final rootContainerFind =
          find.byKey(AccountCell.accountCellBackgroundKey);

      await _build(tester, multiSigAccount, true);
      final theme = tester.widget<Theme>(find.byType(Theme));

      var rootContainer = tester.widget<Container>(rootContainerFind);
      expect(rootContainer.color, theme.data.colorScheme.secondary650);

      await _build(tester, multiSigAccount, false);

      rootContainer = tester.widget<Container>(rootContainerFind);
      expect(rootContainer.color, theme.data.colorScheme.neutral700);
    });

    testWidgets("only AccountContainer is present", (tester) async {
      await _build(tester, multiSigAccount, true);
      expect(find.byType(AccountContainer), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.byType(LinkedAccount), findsOneWidget);
    });

    testWidgets("AccountContainer contents match the account details",
        (tester) async {
      await _build(tester, multiSigAccount, true);
      final accountContainerFind = find.byType(AccountContainer);
      final accountContainer =
          tester.widget<AccountContainer>(accountContainerFind);
      expect(accountContainer.rows.length, 3);
      expect(accountContainer.isSelected, true);
      expect(accountContainer.onShowMenu, isNotNull);

      expect(accountContainer.rows[0] is AccountTitleRow, true);
      expect(accountContainer.rows[1] is AccountDescriptionRow, true);
      expect(accountContainer.rows[2] is AccountNetworkRow, true);
    });

    testWidgets("Show menu options", (tester) async {
      await _build(tester, multiSigAccount, true);

      final accountContainerFind = find.byType(AccountContainer);
      final accountContainer =
          tester.widget<AccountContainer>(accountContainerFind);

      accountContainer.onShowMenu!();
      await tester.pumpAndSettle(Duration(milliseconds: 600));
      final menuFind = find.byKey(AccountCell.accountCellMenuKey);
      final menuItemsFind =
          find.descendant(of: menuFind, matching: find.byType(PwGreyButton));

      final menuItems = tester.widgetList<PwGreyButton>(menuItemsFind).toList();
      expect(menuItems.length, 2);
      expect(menuItems[0].text, strings!.accountMenuItemViewInvite);
      expect(menuItems[1].text, strings!.remove);
    });

    testWidgets("Show menu options with transactable account", (tester) async {
      final transactableAccount = MultiTransactableAccount(
          id: multiSigAccount.id,
          name: multiSigAccount.name,
          linkedAccount: multiSigAccount.linkedAccount,
          remoteId: multiSigAccount.remoteId,
          cosignerCount: multiSigAccount.cosignerCount,
          signaturesRequired: multiSigAccount.signaturesRequired,
          inviteIds: multiSigAccount.inviteIds,
          publicKey: aminoPublicKey);

      await _build(tester, transactableAccount, true);

      final accountContainerFind = find.byType(AccountContainer);
      final accountContainer =
          tester.widget<AccountContainer>(accountContainerFind);

      accountContainer.onShowMenu!();
      await tester.pumpAndSettle(Duration(milliseconds: 600));
      final menuFind = find.byKey(AccountCell.accountCellMenuKey);
      final menuItemsFind =
          find.descendant(of: menuFind, matching: find.byType(PwGreyButton));

      final menuItems = tester.widgetList<PwGreyButton>(menuItemsFind).toList();
      expect(menuItems.length, 3);
      expect(menuItems[0].text, strings!.copyAccountAddress);
      expect(menuItems[1].text, strings!.accountMenuItemViewInvite);
      expect(menuItems[2].text, strings!.remove);
    });

    group("Copy menu item clicked", () {
      final transactableAccount = MultiTransactableAccount(
          id: multiSigAccount.id,
          name: multiSigAccount.name,
          linkedAccount: multiSigAccount.linkedAccount,
          remoteId: multiSigAccount.remoteId,
          cosignerCount: multiSigAccount.cosignerCount,
          signaturesRequired: multiSigAccount.signaturesRequired,
          inviteIds: multiSigAccount.inviteIds,
          publicKey: aminoPublicKey);

      testWidgets("Snackbar displays properly", (tester) async {
        final menuFind = await _buildAndShowMenu(tester, transactableAccount);

        await tester
            .tap(find.descendant(
                of: menuFind, matching: find.text(strings!.copyAccountAddress)))
            .then((_) => tester.pump(Duration(milliseconds: 600)));

        expect(copiedString, transactableAccount.address);

        final snackBarFind = find.byType(SnackBar, skipOffstage: false);
        expect(snackBarFind, findsOneWidget);

        expect(
            find.descendant(
                of: snackBarFind, matching: find.text(strings!.addressCopied)),
            findsOneWidget);
      });
    });

    group("View invite menu item clicked", () {
      late MockMultiSigClient mockMultiSigClient;
      late MockAccountService mockAccountService;

      setUp(() {
        mockMultiSigClient = MockMultiSigClient();
        mockAccountService = MockAccountService();

        get.registerSingleton<MultiSigClient>(mockMultiSigClient);
        get.registerSingleton<AccountService>(mockAccountService);
        get.registerSingleton<DeepLinkService>(MockDeepLinkService());
        when(mockAccountService.getAccount(any)).thenFuture(multiAccount);
        when(mockAccountService.events).thenReturn(AccountServiceEvents());
      });

      tearDown(() {
        get.reset(dispose: false);
      });

      testWidgets("Rename dialog appears when the menu is clicked",
          (tester) async {
        final menuFind = await _buildAndShowMenu(tester, multiSigAccount);

        await tester
            .tap(find.descendant(
                of: menuFind,
                matching: find.text(strings!.accountMenuItemViewInvite)))
            .then((_) => tester.pump(Duration(milliseconds: 600)));
      });
    });
  });
}
