import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_imp.dart';
import 'package:provenance_wallet/services/account_service/wallet_storage_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/sqlite_account_storage_service.dart';

import 'account_storage_service_imp_test.mocks.dart';

final seed = Mnemonic.createSeed(
  Mnemonic.fromEntropy(List.generate(256, (index) => index)),
);
final privateKeys = [
  PrivateKey.fromSeed(seed, Coin.mainNet),
  PrivateKey.fromSeed(seed, Coin.testNet),
];
final publicKeys = privateKeys.map((e) {
  final publicKey = e.defaultKey().publicKey;

  return PublicKeyData(
    address: publicKey.address,
    hex: publicKey.compressedPublicKeyHex,
    chainId: publicKey.coin.chainId,
  );
}).toList();

final selectedPrivateKey = privateKeys.first;
final selectedPublicKey = publicKeys.first;

final details = AccountDetails(
  id: "1",
  address: "Addr",
  name: "Account1",
  publicKey: selectedPublicKey.hex,
  coin: selectedPrivateKey.coin,
);
final details2 = AccountDetails(
  id: "2",
  address: "Add2",
  name: "Account2",
  publicKey: selectedPublicKey.hex,
  coin: selectedPrivateKey.coin,
);

@GenerateMocks([SqliteAccountStorageService, CipherService])
main() {
  MockSqliteAccountStorageService? mockSqliteAccountStorageService;
  MockCipherService? mockCipherService;
  AccountStorageServiceImp? accountStorageService;

  setUp(() {
    mockCipherService = MockCipherService();
    mockSqliteAccountStorageService = MockSqliteAccountStorageService();

    accountStorageService = AccountStorageServiceImp(
      mockSqliteAccountStorageService!,
      mockCipherService!,
    );
  });

  group("addWallet", () {
    setUp(() {
      when(mockSqliteAccountStorageService!.addAccount(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
        selectedChainId: anyNamed("selectedChainId"),
      )).thenAnswer((_) => Future.value(details));

      when(mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(true));
    });

    test('success result', () async {
      final outDetails = await accountStorageService!.addAccount(
        name: "New Name",
        privateKeys: privateKeys,
        selectedCoin: selectedPrivateKey.coin,
      );

      expect(outDetails, details);
    });

    test('call sequence', () async {
      await accountStorageService!.addAccount(
        name: "New Name",
        privateKeys: privateKeys,
        selectedCoin: selectedPrivateKey.coin,
      );

      verify(mockSqliteAccountStorageService!.addAccount(
        name: "New Name",
        publicKeys: publicKeys,
        selectedChainId: ChainId.forCoin(selectedPrivateKey.coin),
      ));

      for (final privateKey in privateKeys) {
        final keyId = accountStorageService!.privateKeyId(
          details.id,
          privateKey.coin,
        );

        verify(mockCipherService!.encryptKey(
          id: keyId,
          privateKey: privateKey.serialize(publicKeyOnly: false),
        ));
      }
    });

    test("no details found", () async {
      when(mockSqliteAccountStorageService!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(12));

      when(mockSqliteAccountStorageService!.addAccount(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
        selectedChainId: anyNamed("selectedChainId"),
      )).thenAnswer((_) => Future.value(null));

      final result = await accountStorageService!.addAccount(
        name: "New Name",
        privateKeys: privateKeys,
        selectedCoin: selectedPrivateKey.coin,
      );

      expect(result, null);
      verifyNoMoreInteractions(mockCipherService!);

      verify(mockSqliteAccountStorageService!.addAccount(
        name: "New Name",
        publicKeys: publicKeys,
        selectedChainId: ChainId.forCoin(selectedPrivateKey.coin),
      ));
      verifyNoMoreInteractions(mockSqliteAccountStorageService!);
    });

    test("error encrypting the key", () async {
      when(mockSqliteAccountStorageService!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(12));

      when(mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(false));

      final result = await accountStorageService!.addAccount(
        name: "New Name",
        privateKeys: privateKeys,
        selectedCoin: selectedPrivateKey.coin,
      );

      expect(result, null);
      verify(mockSqliteAccountStorageService!.removeAccount(id: details.id));
    });

    test('add wallet error', () async {
      final exception = Exception("A");

      when(mockSqliteAccountStorageService!.addAccount(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
        selectedChainId: anyNamed("selectedChainId"),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.addAccount(
          name: "New Name",
          privateKeys: privateKeys,
          selectedCoin: selectedPrivateKey.coin,
        ),
        throwsA(exception),
      );
    });

    test('add encrypt error', () async {
      final exception = Exception("A");

      when(mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.addAccount(
          name: "New Name",
          privateKeys: privateKeys,
          selectedCoin: selectedPrivateKey.coin,
        ),
        throwsA(exception),
      );
    });
  });

  group("getSelectedWallet", () {
    test("results", () async {
      when(mockSqliteAccountStorageService!.getSelectedAccount())
          .thenAnswer((_) => Future.value(details));
      expect(details, await accountStorageService!.getSelectedAccount());
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockSqliteAccountStorageService!.getSelectedAccount())
          .thenAnswer((_) => Future.error(exception));
      expect(
        () => accountStorageService!.getSelectedAccount(),
        throwsA(exception),
      );
    });
  });

  group("getWallet", () {
    test("results", () async {
      when(mockSqliteAccountStorageService!.getAccount(id: anyNamed('id')))
          .thenAnswer((_) => Future.value(details));
      expect(details, await accountStorageService!.getAccount("AB"));
      verify(mockSqliteAccountStorageService!.getAccount(id: "AB"));
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockSqliteAccountStorageService!.getAccount(id: anyNamed('id')))
          .thenAnswer((_) => Future.error(exception));
      expect(
        () => accountStorageService!.getAccount('AB'),
        throwsA(exception),
      );
    });
  });

  group("getWallets", () {
    test("results", () async {
      when(mockSqliteAccountStorageService!.getAccounts())
          .thenAnswer((_) => Future.value([details, details2]));
      expect([details, details2], await accountStorageService!.getAccounts());
      verify(mockSqliteAccountStorageService!.getAccounts());
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockSqliteAccountStorageService!.getAccounts())
          .thenAnswer((_) => Future.error(exception));
      expect(
        () => accountStorageService!.getAccounts(),
        throwsA(exception),
      );
    });
  });

  group("loadKey", () {
    test("results", () async {
      when(mockCipherService!.decryptKey(id: anyNamed("id"))).thenAnswer(
        (_) => Future.value(selectedPrivateKey.serialize(publicKeyOnly: false)),
      );

      const walletId = "A";
      final coin = selectedPrivateKey.coin;
      final keyId = accountStorageService!.privateKeyId(walletId, coin);

      final result = await accountStorageService!.loadKey(walletId, coin);
      expect(result!.rawHex, selectedPrivateKey.rawHex);
      verify(mockCipherService!.decryptKey(id: keyId));
    });

    test("results", () async {
      when(mockCipherService!.decryptKey(id: anyNamed("id"))).thenAnswer(
        (_) => Future.value(null),
      );

      final result = await accountStorageService!.loadKey("A", Coin.testNet);
      expect(result, null);
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockCipherService!.decryptKey(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.loadKey("A", Coin.testNet),
        throwsA(exception),
      );
    });
  });

  group("removeAllWallets", () {
    setUp(() {
      when(mockCipherService!.resetKeys()).thenAnswer(
        (_) => Future.value(true),
      );

      when(mockSqliteAccountStorageService!.removeAllAccounts())
          .thenAnswer((_) => Future.value(4));
    });

    test("results", () async {
      final result = await accountStorageService!.removeAllAccounts();
      expect(result, true);
    });

    test("function calls", () async {
      await accountStorageService!.removeAllAccounts();
      verify(mockCipherService!.resetKeys());
      verify(mockSqliteAccountStorageService!.removeAllAccounts());
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockCipherService!.resetKeys())
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.removeAllAccounts(),
        throwsA(exception),
      );
    });

    test("error during remove wallets", () async {
      final exception = Exception("A");

      when(mockSqliteAccountStorageService!.removeAllAccounts())
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.removeAllAccounts(),
        throwsA(exception),
      );
    });
  });

  group("removeWallet", () {
    setUp(() {
      when(mockCipherService!.removeKey(id: anyNamed("id"))).thenAnswer(
        (_) => Future.value(true),
      );

      when(mockSqliteAccountStorageService!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(4));
    });

    test("results", () async {
      final result = await accountStorageService!.removeAccount("AB");
      expect(result, true);
    });

    test("function calls", () async {
      const id = "AB";
      await accountStorageService!.removeAccount(id);

      for (final coin in Coin.values) {
        final keyId = accountStorageService!.privateKeyId(
          id,
          coin,
        );

        verify(mockCipherService!.removeKey(id: keyId));
      }
      verify(mockSqliteAccountStorageService!.removeAccount(id: "AB"));
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockCipherService!.removeKey(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.removeAccount("AB"),
        throwsA(exception),
      );
    });

    test("error during remove wallets", () async {
      final exception = Exception("A");

      when(mockSqliteAccountStorageService!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.removeAccount("AB"),
        throwsA(exception),
      );
    });
  });

  group("renameWallet", () {
    test("results", () async {
      when(mockSqliteAccountStorageService!
              .renameAccount(id: anyNamed("id"), name: anyNamed("name")))
          .thenAnswer((realInvocation) => Future.value(details));

      final result =
          await accountStorageService!.renameAccount(id: "AB", name: "NewName");

      expect(result, details);
    });

    test("function calls", () async {
      when(mockSqliteAccountStorageService!
              .renameAccount(id: anyNamed("id"), name: anyNamed("name")))
          .thenAnswer((realInvocation) => Future.value(details));

      await accountStorageService!.renameAccount(id: "AB", name: "NewName");

      verify(mockSqliteAccountStorageService!
          .renameAccount(id: "AB", name: "NewName"));
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockSqliteAccountStorageService!
              .renameAccount(id: anyNamed("id"), name: anyNamed("name")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.renameAccount(id: "AB", name: "NewName"),
        throwsA(exception),
      );
    });
  });

  group("selectWallet", () {
    setUp(() {
      when(mockSqliteAccountStorageService!.selectAccount(id: anyNamed("id")))
          .thenAnswer(
        (_) => Future.value(details),
      );
    });

    test("results", () async {
      final result = await accountStorageService!.selectAccount(id: "AB");
      expect(result, details);
    });

    test("function calls", () async {
      await accountStorageService!.selectAccount(id: "AB");
      verify(mockSqliteAccountStorageService!.selectAccount(id: "AB"));
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockSqliteAccountStorageService!.selectAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.selectAccount(id: "AB"),
        throwsA(exception),
      );
    });
  });
}