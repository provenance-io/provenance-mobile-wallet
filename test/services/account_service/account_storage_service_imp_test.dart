import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_imp.dart';
import 'package:provenance_wallet/services/models/account.dart';

import 'account_storage_service_imp_test.mocks.dart';

final seed = Mnemonic.createSeed(
  Mnemonic.fromEntropy(List.generate(256, (index) => index)),
);
final privateKey = PrivateKey.fromSeed(seed, Coin.testNet);
final publicKey = privateKey.defaultKey().publicKey;

final details = BasicAccount(
  id: "1",
  name: "Account1",
  publicKey: publicKey,
);
final details2 = BasicAccount(
  id: "2",
  name: "Account2",
  publicKey: publicKey,
);

@GenerateMocks([AccountStorageServiceCore, CipherService])
main() {
  MockAccountStorageServiceCore? mockAccountStorageServiceCore;
  MockCipherService? mockCipherService;
  AccountStorageServiceImp? accountStorageService;

  setUp(() {
    mockCipherService = MockCipherService();
    mockAccountStorageServiceCore = MockAccountStorageServiceCore();

    accountStorageService = AccountStorageServiceImp(
      mockAccountStorageServiceCore!,
      mockCipherService!,
    );
  });

  group("addWallet", () {
    setUp(() {
      when(mockAccountStorageServiceCore!.addBasicAccount(
        name: anyNamed("name"),
        publicKey: anyNamed("publicKey"),
      )).thenAnswer((_) => Future.value(details));

      when(mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(true));
    });

    test('success result', () async {
      final outDetails = await accountStorageService!.addAccount(
        name: "New Name",
        privateKey: privateKey,
      );

      expect(outDetails, details);
    });

    test('call sequence', () async {
      await accountStorageService!.addAccount(
        name: "New Name",
        privateKey: privateKey,
      );

      verify(mockAccountStorageServiceCore!.addBasicAccount(
        name: "New Name",
        publicKey: PublicKeyData(
          hex: publicKey.compressedPublicKeyHex,
          chainId: ChainId.forCoin(publicKey.coin),
        ),
      ));

      final keyId = accountStorageService!.privateKeyId(
        details.id,
        privateKey.coin,
      );

      verify(mockCipherService!.encryptKey(
        id: keyId,
        privateKey: privateKey.serialize(publicKeyOnly: false),
      ));
    });

    test("no details found", () async {
      when(mockAccountStorageServiceCore!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(12));

      when(mockAccountStorageServiceCore!.addBasicAccount(
        name: anyNamed("name"),
        publicKey: anyNamed("publicKey"),
      )).thenAnswer((_) => Future.value(null));

      final result = await accountStorageService!.addAccount(
        name: "New Name",
        privateKey: privateKey,
      );

      expect(result, null);
      verifyNoMoreInteractions(mockCipherService!);

      verify(mockAccountStorageServiceCore!.addBasicAccount(
        name: "New Name",
        publicKey: PublicKeyData(
          hex: publicKey.compressedPublicKeyHex,
          chainId: ChainId.forCoin(publicKey.coin),
        ),
      ));
      verifyNoMoreInteractions(mockAccountStorageServiceCore!);
    });

    test("error encrypting the key", () async {
      when(mockAccountStorageServiceCore!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(12));

      when(mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(false));

      final result = await accountStorageService!.addAccount(
        name: "New Name",
        privateKey: privateKey,
      );

      expect(result, null);
      verify(mockAccountStorageServiceCore!.removeAccount(id: details.id));
    });

    test('add wallet error', () async {
      final exception = Exception("A");

      when(mockAccountStorageServiceCore!.addBasicAccount(
        name: anyNamed("name"),
        publicKey: anyNamed("publicKey"),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.addAccount(
          name: "New Name",
          privateKey: privateKey,
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
          privateKey: privateKey,
        ),
        throwsA(exception),
      );
    });
  });

  group("getSelectedWallet", () {
    test("results", () async {
      when(mockAccountStorageServiceCore!.getSelectedAccount())
          .thenAnswer((_) => Future.value(details));
      expect(details, await accountStorageService!.getSelectedAccount());
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockAccountStorageServiceCore!.getSelectedAccount())
          .thenAnswer((_) => Future.error(exception));
      expect(
        () => accountStorageService!.getSelectedAccount(),
        throwsA(exception),
      );
    });
  });

  group("getWallet", () {
    test("results", () async {
      when(mockAccountStorageServiceCore!.getAccount(id: anyNamed('id')))
          .thenAnswer((_) => Future.value(details));
      expect(details, await accountStorageService!.getAccount("AB"));
      verify(mockAccountStorageServiceCore!.getAccount(id: "AB"));
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockAccountStorageServiceCore!.getAccount(id: anyNamed('id')))
          .thenAnswer((_) => Future.error(exception));
      expect(
        () => accountStorageService!.getAccount('AB'),
        throwsA(exception),
      );
    });
  });

  group("getWallets", () {
    test("results", () async {
      when(mockAccountStorageServiceCore!.getBasicAccounts())
          .thenAnswer((_) => Future.value([details, details2]));
      expect(
          [details, details2], await accountStorageService!.getBasicAccounts());
      verify(mockAccountStorageServiceCore!.getBasicAccounts());
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockAccountStorageServiceCore!.getBasicAccounts())
          .thenAnswer((_) => Future.error(exception));
      expect(
        () => accountStorageService!.getBasicAccounts(),
        throwsA(exception),
      );
    });
  });

  group("loadKey", () {
    test("results", () async {
      when(mockCipherService!.decryptKey(id: anyNamed("id"))).thenAnswer(
        (_) => Future.value(privateKey.serialize(publicKeyOnly: false)),
      );

      const walletId = "A";
      final coin = privateKey.coin;
      final keyId = accountStorageService!.privateKeyId(walletId, coin);

      final result = await accountStorageService!.loadKey(walletId, coin);
      expect(result!.rawHex, privateKey.rawHex);
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

      when(mockAccountStorageServiceCore!.removeAllAccounts())
          .thenAnswer((_) => Future.value(4));
    });

    test("results", () async {
      final result = await accountStorageService!.removeAllAccounts();
      expect(result, true);
    });

    test("function calls", () async {
      await accountStorageService!.removeAllAccounts();
      verify(mockCipherService!.resetKeys());
      verify(mockAccountStorageServiceCore!.removeAllAccounts());
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

      when(mockAccountStorageServiceCore!.removeAllAccounts())
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

      when(mockAccountStorageServiceCore!.removeAccount(id: anyNamed("id")))
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
      verify(mockAccountStorageServiceCore!.removeAccount(id: "AB"));
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

      when(mockAccountStorageServiceCore!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.removeAccount("AB"),
        throwsA(exception),
      );
    });
  });

  group("renameWallet", () {
    test("results", () async {
      when(mockAccountStorageServiceCore!
              .renameAccount(id: anyNamed("id"), name: anyNamed("name")))
          .thenAnswer((realInvocation) => Future.value(details));

      final result =
          await accountStorageService!.renameAccount(id: "AB", name: "NewName");

      expect(result, details);
    });

    test("function calls", () async {
      when(mockAccountStorageServiceCore!
              .renameAccount(id: anyNamed("id"), name: anyNamed("name")))
          .thenAnswer((realInvocation) => Future.value(details));

      await accountStorageService!.renameAccount(id: "AB", name: "NewName");

      verify(mockAccountStorageServiceCore!
          .renameAccount(id: "AB", name: "NewName"));
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockAccountStorageServiceCore!
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
      when(mockAccountStorageServiceCore!.selectAccount(id: anyNamed("id")))
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
      verify(mockAccountStorageServiceCore!.selectAccount(id: "AB"));
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockAccountStorageServiceCore!.selectAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => accountStorageService!.selectAccount(id: "AB"),
        throwsA(exception),
      );
    });
  });
}
