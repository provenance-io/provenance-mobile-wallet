import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service_imp.dart';

import 'wallet_storage_service_imp_test.mocks.dart';

const coin = Coin.testNet;
final seed = Mnemonic.createSeed(
  Mnemonic.fromEntropy(List.generate(256, (index) => index)),
);
final privateKey = PrivateKey.fromSeed(seed, coin);
final publicKey = privateKey.defaultKey().publicKey;
final details = WalletDetails(
  id: "1",
  address: "Addr",
  name: "Wallet1",
  publicKey: publicKey.compressedPublicKeyHex,
  coin: coin,
);
final details2 = WalletDetails(
  id: "2",
  address: "Add2",
  name: "Wallet2",
  publicKey: publicKey.compressedPublicKeyHex,
  coin: coin,
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
        address: anyNamed("address"),
        coin: anyNamed("coin"),
        publicKey: anyNamed("publicKey"),
      )).thenAnswer((_) => Future.value(details));

      when(mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(true));
    });

    test('success result', () async {
      final outDetails = await walletStorageService!
          .addWallet(name: "New Name", privateKey: privateKey);

      expect(outDetails, details);
    });

    test('call sequence', () async {
      await walletStorageService!
          .addWallet(name: "New Name", privateKey: privateKey);

      verify(mockSqliteWalletStorageService!.addWallet(
        name: "New Name",
        address: publicKey.address,
        coin: coin,
        publicKey: publicKey.compressedPublicKeyHex,
      ));

      verify(mockCipherService!.encryptKey(
        id: details.id,
        privateKey: privateKey.serialize(publicKeyOnly: false),
      ));
    });

    test("no details found", () async {
      when(mockSqliteWalletStorageService!.removeWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(12));

      when(mockSqliteWalletStorageService!.addWallet(
        name: anyNamed("name"),
        address: anyNamed("address"),
        coin: anyNamed("coin"),
        publicKey: anyNamed("publicKey"),
      )).thenAnswer((_) => Future.value(null));

      final result = await walletStorageService!
          .addWallet(name: "New Name", privateKey: privateKey);

      expect(result, null);
      verifyNoMoreInteractions(mockCipherService!);

      verify(mockSqliteWalletStorageService!.addWallet(
        name: "New Name",
        address: publicKey.address,
        coin: coin,
        publicKey: publicKey.compressedPublicKeyHex,
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
          .addWallet(name: "New Name", privateKey: privateKey);

      expect(result, null);
      verify(mockSqliteWalletStorageService!.removeWallet(id: details.id));
    });

    test('add wallet error', () async {
      final exception = Exception("A");

      when(mockSqliteWalletStorageService!.addWallet(
        name: anyNamed("name"),
        address: anyNamed("address"),
        coin: anyNamed("coin"),
        publicKey: anyNamed("publicKey"),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!
            .addWallet(name: "New Name", privateKey: privateKey),
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
            .addWallet(name: "New Name", privateKey: privateKey),
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
        (_) => Future.value(privateKey.serialize(publicKeyOnly: false)),
      );

      final result = await walletStorageService!.loadKey("A");
      expect(result!.raw, privateKey.raw);
      verify(mockCipherService!.decryptKey(id: "A"));
    });

    test("results", () async {
      when(mockCipherService!.decryptKey(id: anyNamed("id"))).thenAnswer(
        (_) => Future.value(null),
      );

      final result = await walletStorageService!.loadKey("A");
      expect(result, null);
    });

    test("error", () async {
      final exception = Exception("A");

      when(mockCipherService!.decryptKey(id: anyNamed("id")))
          .thenAnswer((_) => Future.error(exception));

      expect(
        () => walletStorageService!.loadKey("A"),
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
      await walletStorageService!.removeWallet("AB");
      verify(mockCipherService!.removeKey(id: "AB"));
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
