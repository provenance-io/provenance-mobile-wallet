import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:rxdart/subjects.dart';

import './accounts_bloc_test.mocks.dart';
import '../../../test_helpers.dart';

const pubKeyHex1 = "AtqS7MRO7zKZ4Azfj0do1bYGv4JC/1J35vB6rdk1JXo3";
const pubKeyHex2 = "A20rKxFRxuXvhRpOZRz3jCzkO91HMDiCDyTHgVevYnzJ";

final pubKey1 = PublicKey.fromCompressPublicHex(
    Base64Decoder().convert(pubKeyHex1), Coin.testNet);

final pubKey2 = PublicKey.fromCompressPublicHex(
    Base64Decoder().convert(pubKeyHex2), Coin.testNet);

final account1 = BasicAccount(
  id: "BasicAccount1Id",
  name: "BasicAccount1Name",
  publicKey: pubKey1,
);

final account2 = BasicAccount(
  id: "BasicAccount2Id",
  name: "BasicAccount2Name",
  publicKey: pubKey2,
);

final aminoPublicKey = AminoPubKey(
    threshold: 2, publicKeys: [pubKey1, pubKey2], coin: Coin.testNet);

final multiSigAccount = MultiTransactableAccount(
    id: "Id1",
    name: "Multisig Account",
    inviteIds: ["A", "B"],
    remoteId: "RemoteId",
    signaturesRequired: 2,
    cosignerCount: 2,
    linkedAccount: account1,
    publicKey: aminoPublicKey);

class _AccountsBlocStateMatcher extends Matcher {
  final List<Account> accounts;
  final String? selectedId;

  _AccountsBlocStateMatcher(this.accounts, this.selectedId);

  @override
  Description describe(Description description) => description;

  @override
  bool matches(item, Map matchState) {
    final arg = item as AccountsBlocState;
    expect(arg.selectedAccount, selectedId);
    expect(arg.accounts, accounts);
    return true;
  }
}

class _MockAccountServiceEvents extends AccountServiceEvents {
  void addAddedEvent(Account account) {
    (added as PublishSubject<Account>).add(account);
  }

  void addRemovedEvent(List<Account> accounts) {
    (removed as PublishSubject<List<Account>>).add(accounts);
  }

  void addUpdatedEvent(Account account) {
    (updated as PublishSubject<Account>).add(account);
  }

  void addSelectedEvent(TransactableAccount account) {
    (selected as BehaviorSubject<TransactableAccount?>).add(account);
  }
}

@GenerateMocks([AccountService, LocalAuthHelper])
void main() {
  late _MockAccountServiceEvents accountEvents;
  late MockAccountService mockAccountService;
  late AccountsBloc bloc;

  setUp(() {
    accountEvents = _MockAccountServiceEvents();

    mockAccountService = MockAccountService();
    when(mockAccountService.events).thenReturn(accountEvents);
    when(mockAccountService.selectAccount(id: anyNamed("id"))).thenFuture(null);
    when(mockAccountService.renameAccount(
            id: anyNamed("id"), name: anyNamed("name")))
        .thenFuture(null);
    when(mockAccountService.getAccounts())
        .thenFuture([account1, multiSigAccount]);
    when(mockAccountService.getSelectedAccount()).thenFuture(account1);

    get.registerSingleton<AccountService>(mockAccountService);

    bloc = AccountsBloc();
  });

  tearDown(() {
    get.reset(dispose: false);
  });

  test("Default stream values", () {
    expect(
      bloc.accountsStream.value,
      _AccountsBlocStateMatcher(<Account>[], null),
    );
    expect(bloc.loading.value, false);
  });

  group("load", () {
    test("loading transitions on success", () async {
      expectLater(bloc.loading, emitsInOrder([false, true, false]));
      expectLater(
          bloc.accountsStream,
          emitsInOrder([
            _AccountsBlocStateMatcher(
                <Account>[account1, multiSigAccount], account1.id),
          ]));

      await bloc.load();
    });

    test("errors during get accounts are rethrown", () async {
      final ex = Exception("ABCDE");
      when(mockAccountService.getAccounts()).thenThrow(ex);

      expectLater(bloc.loading, emitsInOrder([false, true, false]));
      expectLater(bloc.accountsStream, emitsInOrder([]));

      expect(() => bloc.load(), throwsA(ex));
    });

    test("errors during get selected account are rethrown", () async {
      final ex = Exception("ABCDE");
      when(mockAccountService.getSelectedAccount()).thenThrow(ex);

      expectLater(bloc.loading, emitsInOrder([false, true, false]));
      expectLater(bloc.accountsStream, emitsInOrder([]));

      expect(() => bloc.load(), throwsA(ex));
    });
  });

  group("selectAccount", () {
    setUp(() async {
      await bloc.load();
    });

    test("selectAccount is invoked on accountService", () async {
      await bloc.selectAccount(multiSigAccount);
      verify(mockAccountService.selectAccount(id: multiSigAccount.id));
    });
  });

  group("getAccountAtIndex", () {
    setUp(() async {
      await bloc.load();
    });

    test("the account returned for the index matches the order in the state",
        () {
      expect(bloc.getAccountAtIndex(0), account1);
      expect(bloc.getAccountAtIndex(1), multiSigAccount);
    });

    test("an exception is thrown for an invalid range", () {
      expect(() => bloc.getAccountAtIndex(2), throwsRangeError);
      expect(() => bloc.getAccountAtIndex(-1), throwsRangeError);
    });
  });

  group("renameAccount", () {
    test("renameAccount called on accountService", () async {
      await bloc.renameAccount(account1, "TestAccount");

      verify(mockAccountService.renameAccount(
          id: account1.id, name: "TestAccount"));
    });
  });

  group("deleteAccount", () {
    late MockLocalAuthHelper mockLocalAuthHelper;

    setUp(() {
      mockLocalAuthHelper = MockLocalAuthHelper();
      get.registerSingleton<LocalAuthHelper>(mockLocalAuthHelper);

      when(mockAccountService.removeAccount(id: anyNamed("id")))
          .thenFuture(null);

      when(mockAccountService.getAccounts())
          .thenFuture([account1, multiSigAccount]);
    });

    test("verify removeAccount called", () async {
      await bloc.deleteAccount(account1);
      verify(mockAccountService.removeAccount(id: account1.id));
    });

    test("localAuthHelper reset invoked if list is empay", () async {
      when(mockAccountService.removeAccount(id: anyNamed("id")))
          .thenFuture(null);

      await bloc.deleteAccount(account1);
      verifyNever(mockLocalAuthHelper.reset());

      when(mockAccountService.getAccounts()).thenFuture([]);

      await bloc.deleteAccount(account1);
      verify(mockLocalAuthHelper.reset());
    });
  });

  group("dispose", () {
    test("all bloc streams are closed", () {
      bloc.onDispose();

      expect(bloc.accountsStream, StreamClosed(true));
      expect(bloc.loading, StreamClosed(true));
    });
  });

  group("AccountEvents accountAdded", () {
    setUp(() async {
      await bloc.load();
    });

    test("The list is updated when an account is added", () async {
      when(mockAccountService.getAccounts())
          .thenFuture([account1, multiSigAccount, account2]);

      expectLater(
          bloc.accountsStream.skip(1),
          emitsInOrder([
            _AccountsBlocStateMatcher(
                <Account>[account1, multiSigAccount, account2], account1.id),
          ]));

      accountEvents.addAddedEvent(account2);
    });
  });

  group("AccountEvents accountsRemoved", () {
    setUp(() async {
      await bloc.load();
    });

    test("The list is updated when an account is added", () async {
      when(mockAccountService.getAccounts()).thenFuture([account1]);

      expectLater(
          bloc.accountsStream.skip(1),
          emitsInOrder([
            _AccountsBlocStateMatcher(<Account>[
              account1,
            ], account1.id),
          ]));

      accountEvents.addRemovedEvent([multiSigAccount]);
    });
  });

  group("AccountEvents accountUpdated", () {
    setUp(() async {
      await bloc.load();
    });

    test("The list is updated when an account is added", () async {
      final modifiedAccount1 = BasicAccount(
        id: account1.id,
        name: "NewAccount1Name",
        publicKey: account1.publicKey,
      );

      when(mockAccountService.getAccounts())
          .thenFuture([modifiedAccount1, multiSigAccount]);

      expectLater(
          bloc.accountsStream.skip(1),
          emitsInOrder([
            _AccountsBlocStateMatcher(
                <Account>[modifiedAccount1, multiSigAccount], account1.id),
          ]));

      accountEvents.addUpdatedEvent(modifiedAccount1);
    });
  });

  group("AccountEvents accountSelected", () {
    setUp(() async {
      await bloc.load();
    });

    test("The list is updated when the selected account is changed", () async {
      when(mockAccountService.getSelectedAccount()).thenFuture(multiSigAccount);
      expectLater(
          bloc.accountsStream.skip(1),
          emitsInOrder([
            _AccountsBlocStateMatcher(
                <Account>[multiSigAccount, account1], multiSigAccount.id),
          ]));

      accountEvents.addSelectedEvent(multiSigAccount);
    });
  });
}
