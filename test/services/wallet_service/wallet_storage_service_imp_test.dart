import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service_imp.dart';

import 'wallet_storage_service_imp_test.mocks.dart';

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

final details = WalletDetails(
  id: "1",
  address: "Addr",
  name: "Wallet1",
  publicKey: selectedPublicKey.hex,
  coin: selectedPrivateKey.coin,
);
final details2 = WalletDetails(
  id: "2",
  address: "Add2",
  name: "Wallet2",
  publicKey: selectedPublicKey.hex,
  coin: selectedPrivateKey.coin,
);

@GenerateMocks([SqliteWalletStorageService, CipherService])
main() {
  MockSqliteWalletStorageService? mockSqliteWalletStorageService;
  MockCipherService? mockCipherService;
  WalletStorageServiceImp? walletStorageService;

  setUp(() {
    mockCipherService = MockCipherService();
    mockSqliteWalletStorageService = MockSqliteWalletStorageService();

    walletStorageService = WalletStorageServiceImp(
      mockSqliteWalletStorageService!,
      mockCipherService!,
    );
  });

  group("addWallet", () {
    setUp(() {
      when(mockSqliteWalletStorageService!.addWallet(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
      )).thenAnswer((_) => Future.value(details));

      when(mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(true));
    });

    test('success result', () async {
      final outDetails = await walletStorageService!
          .addWallet(name: "New Name", privateKeys: privateKeys);

      expect(outDetails, details);
    });

    test('call sequence', () async {
      await walletStorageService!
          .addWallet(name: "New Name", privateKeys: privateKeys);

      verify(mockSqliteWalletStorageService!.addWallet(
        name: "New Name",
        publicKeys: publicKeys,
      ));

      for (final privateKey in privateKeys) {
        final keyId = walletStorageService!.privateKeyId(
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
      when(mockSqliteWalletStorageService!.removeWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(12));

      when(mockSqliteWalletStorageService!.addWallet(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
      )).thenAnswer((_) => Future.value(null));

      final result = await walletStorageService!
          .addWallet(name: "New Name", privateKeys: privateKeys);

      expect(result, null);
      verifyNoMoreInteractions(mockCipherService!);

      verify(mockSqliteWalletStorageService!.addWallet(
        name: "New Name",
        publicKeys: publicKeys,
      ));
      verifyNoMoreInteractions(mockSqliteWalletStorageService!);
    });

    test("error encrypting the key", () async {
      when(mockSqliteWalletStorageService!.removeWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(12));

      when(mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(false));

      final result = await walletStorageService!
          .addWallet(name: "New Name", privateKeys: privateKeys);

      expect(result, null);
      verify(mockSqliteWalletStorageService!.removeWallet(id: details.id));
    });

    test('add wallet error', () async {
      final exception = Exception("A");

      when(mockSqliteWalletStorageService!.addWallet(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!
            .addWallet(name: "New Name", privateKeys: privateKeys),
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
        () => walletStorageService!
            .addWallet(name: "New Name", privateKeys: privateKeys),
        throwsA(exception),
      );
    });
  });

  group("getSelectedWallet", () {
    test("results", () async {
      when(mockSqliteWalletStorageService!.getSelectedWallet())
          .thenAnswer((_) => Future.value(details));
      expect(details, await walletStorageService!.getSelectedWallet());
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockSqliteWalletStorageService!.getSelectedWallet())
          .thenAnswer((_) => Future.error(exception));
      expect(
        () => walletStorageService!.getSelectedWallet(),
        throwsA(exception),
      );
    });
  });

  group("getWallet", () {
    test("results", () async {
      when(mockSqliteWalletStorageService!.getWallet(id: anyNamed('id')))
          .thenAnswer((_) => Future.value(details));
      expect(details, await walletStorageService!.getWallet("AB"));
      verify(mockSqliteWalletStorageService!.getWallet(id: "AB"));
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockSqliteWalletStorageService!.getWallet(id: anyNamed('id')))
          .thenAnswer((_) => Future.error(exception));
      expect(
        () => walletStorageService!.getWallet('AB'),
        throwsA(exception),
      );
    });
  });

  group("getWallets", () {
    test("results", () async {
      when(mockSqliteWalletStorageService!.getWallets())
          .thenAnswer((_) => Future.value([details, details2]));
      expect([details, details2], await walletStorageService!.getWallets());
      verify(mockSqliteWalletStorageService!.getWallets());
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockSqliteWalletStorageService!.getWallets())
          .thenAnswer((_) => Future.error(exception));
      expect(
        () => walletStorageService!.getWallets(),
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
      final keyId = walletStorageService!.privateKeyId(walletId, coin);

      final result = await walletStorageService!.loadKey(walletId, coin);
      expect(result!.rawHex, selectedPrivateKey.rawHex);
      verify(mockCipherService!.decryptKey(id: keyId));
    });

    test("results", () async {
      when(mockCipherService!.decryptKey(id: anyNamed("id"))).thenAnswer(
        (_) => Future.value(null),
      );

      final result = await walletStorageService!.loadKey("A", Coin.testNet);
      expect(result, null);
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockCipherService!.decryptKey(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!.loadKey("A", Coin.testNet),
        throwsA(exception),
      );
    });
  });

  group("removeAllWallets", () {
    setUp(() {
      when(mockCipherService!.reset()).thenAnswer(
        (_) => Future.value(true),
      );

      when(mockSqliteWalletStorageService!.removeAllWallets())
          .thenAnswer((_) => Future.value(4));
    });

    test("results", () async {
      final result = await walletStorageService!.removeAllWallets();
      expect(result, true);
    });

    test("function calls", () async {
      await walletStorageService!.removeAllWallets();
      verify(mockCipherService!.reset());
      verify(mockSqliteWalletStorageService!.removeAllWallets());
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockCipherService!.reset())
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!.removeAllWallets(),
        throwsA(exception),
      );
    });

    test("error during remove wallets", () async {
      final exception = Exception("A");

      when(mockSqliteWalletStorageService!.removeAllWallets())
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!.removeAllWallets(),
        throwsA(exception),
      );
    });
  });

  group("removeWallet", () {
    setUp(() {
      when(mockCipherService!.removeKey(id: anyNamed("id"))).thenAnswer(
        (_) => Future.value(true),
      );

      when(mockSqliteWalletStorageService!.removeWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(4));
    });

    test("results", () async {
      final result = await walletStorageService!.removeWallet("AB");
      expect(result, true);
    });

    test("function calls", () async {
      const id = "AB";
      await walletStorageService!.removeWallet(id);

      for (final coin in Coin.values) {
        final keyId = walletStorageService!.privateKeyId(
          id,
          coin,
        );

        verify(mockCipherService!.removeKey(id: keyId));
      }
      verify(mockSqliteWalletStorageService!.removeWallet(id: "AB"));
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockCipherService!.removeKey(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!.removeWallet("AB"),
        throwsA(exception),
      );
    });

    test("error during remove wallets", () async {
      final exception = Exception("A");

      when(mockSqliteWalletStorageService!.removeWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!.removeWallet("AB"),
        throwsA(exception),
      );
    });
  });

  group("renameWallet", () {
    test("results", () async {
      when(mockSqliteWalletStorageService!
              .renameWallet(id: anyNamed("id"), name: anyNamed("name")))
          .thenAnswer((realInvocation) => Future.value(details));

      final result =
          await walletStorageService!.renameWallet(id: "AB", name: "NewName");

      expect(result, details);
    });

    test("function calls", () async {
      when(mockSqliteWalletStorageService!
              .renameWallet(id: anyNamed("id"), name: anyNamed("name")))
          .thenAnswer((realInvocation) => Future.value(details));

      await walletStorageService!.renameWallet(id: "AB", name: "NewName");

      verify(mockSqliteWalletStorageService!
          .renameWallet(id: "AB", name: "NewName"));
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockSqliteWalletStorageService!
              .renameWallet(id: anyNamed("id"), name: anyNamed("name")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!.renameWallet(id: "AB", name: "NewName"),
        throwsA(exception),
      );
    });
  });

  group("selectWallet", () {
    setUp(() {
      when(mockSqliteWalletStorageService!.selectWallet(id: anyNamed("id")))
          .thenAnswer(
        (_) => Future.value(details),
      );
    });

    test("results", () async {
      final result = await walletStorageService!.selectWallet(id: "AB");
      expect(result, details);
    });

    test("function calls", () async {
      await walletStorageService!.selectWallet(id: "AB");
      verify(mockSqliteWalletStorageService!.selectWallet(id: "AB"));
    });

    test("error during cipher reset", () async {
      final exception = Exception("A");

      when(mockSqliteWalletStorageService!.selectWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!.selectWallet(id: "AB"),
        throwsA(exception),
      );
    });
  });
}
