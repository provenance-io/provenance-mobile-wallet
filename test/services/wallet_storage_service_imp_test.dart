import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service_imp.dart';

import 'wallet_storage_service_imp_test.mocks.dart';

@GenerateMocks([SqliteWalletStorageService, CipherService])
main() {
  MockSqliteWalletStorageService? _mockSqliteService;
  MockCipherService? _mockCipherService;

  WalletStorageServiceImp? _storageService;

  setUp(() {
    _mockSqliteService = MockSqliteWalletStorageService();
    _mockCipherService = MockCipherService();

    _storageService =
        WalletStorageServiceImp(_mockSqliteService!, _mockCipherService!);
  });

  group("addWallet", () {
    PrivateKey? privateKey;
    const id = "TestId";

    setUp(() {
      const bip32Serialized =
          "tprv8kxV73NnPZyfSNfQThb5zjzysmbmGABtrZsGNcuhKnqPsmJFuyBvwJzSA24V59AAYWJfBVGxu4fGSKiLh3czp6kE1NNpP2SqUvHeStr8DC1";
      privateKey = PrivateKey.fromBip32(bip32Serialized);
    });

    test('success', () async {
      when(_mockSqliteService!.addWallet(
        name: anyNamed("name"),
        address: anyNamed("address"),
        coin: anyNamed("coin"),
      )).thenAnswer((_) => Future.value(id));

      when(_mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
        useBiometry: anyNamed("useBiometry"),
      )).thenAnswer((_) => Future.value(true));

      final result = await _storageService!.addWallet(
        name: "Name",
        privateKey: privateKey!,
        useBiometry: true,
      );

      expect(result, true);

      verify(_mockSqliteService!.addWallet(
        name: "Name",
        address: privateKey!.defaultKey().publicKey.address,
        coin: Coin.testNet,
      ));

      verify(_mockCipherService!.encryptKey(
        id: id,
        privateKey: privateKey!.serialize(publicKeyOnly: false),
        useBiometry: true,
      ));
    });

    testWidgets('add wallet failure', (tester) async {
      final exception = Exception("Error");

      when(_mockSqliteService!.addWallet(
        name: anyNamed("name"),
        address: anyNamed("address"),
        coin: anyNamed("coin"),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => _storageService!.addWallet(
          name: "Name",
          privateKey: privateKey!,
          useBiometry: true,
        ),
        throwsA(exception),
      );

      verifyNoMoreInteractions(_mockCipherService);
    });

    testWidgets('error while encrypting key', (tester) async {
      when(_mockSqliteService!.removeWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.value());
      when(_mockSqliteService!.addWallet(
        name: anyNamed("name"),
        address: anyNamed("address"),
        coin: anyNamed("coin"),
      )).thenAnswer((_) => Future.value(id));

      when(_mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
        useBiometry: anyNamed("useBiometry"),
      )).thenAnswer((_) => Future.value(false));

      final result = await _storageService!.addWallet(
        name: "Name",
        privateKey: privateKey!,
        useBiometry: true,
      );

      verify(_mockSqliteService!.removeWallet(id: id));

      expect(result, false);
    });
  });

  group("getSelectedWallet", () {
    test("success", () async {
      final walletDetails = WalletDetails(
        id: "id1",
        address: "Address1",
        name: "Name1",
      );

      when(_mockSqliteService!.getSelectedWallet())
          .thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.getSelectedWallet();
      expect(result, walletDetails);
    });
  });

  group("getWallet", () {
    test("success", () async {
      final walletDetails = WalletDetails(
        id: "id1",
        address: "Address1",
        name: "Name1",
      );

      when(_mockSqliteService!.getWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.getWallet("walletId");
      expect(result, walletDetails);
      verify(_mockSqliteService!.getWallet(id: "walletId"));
    });
  });

  group("getWallets", () {
    test("success", () async {
      final walletDetails = [
        WalletDetails(
          id: "id1",
          address: "Address1",
          name: "Name1",
        ),
        WalletDetails(
          id: "id2",
          address: "Address2",
          name: "Name2",
        ),
      ];

      when(_mockSqliteService!.getWallets())
          .thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.getWallets();
      expect(result, walletDetails);
    });
  });

  group("loadKey", () {
    const bip32Serialized =
        "tprv8kxV73NnPZyfSNfQThb5zjzysmbmGABtrZsGNcuhKnqPsmJFuyBvwJzSA24V59AAYWJfBVGxu4fGSKiLh3czp6kE1NNpP2SqUvHeStr8DC1";
    const id = "TestId";

    testWidgets('success', (tester) async {
      when(_mockCipherService!.decryptKey(
        id: anyNamed("id"),
      )).thenAnswer((_) => Future.value(bip32Serialized));

      final privateKey = await _storageService!.loadKey(id);
      expect(privateKey!.rawHex, PrivateKey.fromBip32(bip32Serialized).rawHex);
      verify(_mockCipherService!.decryptKey(id: id));
      verifyNoMoreInteractions(_mockSqliteService);
    });
  });

  group("removeAllWallets", () {
    testWidgets('success', (tester) async {
      when(_mockCipherService!.reset()).thenAnswer((_) => Future.value(true));
      when(_mockSqliteService!.removeAllWallets())
          .thenAnswer((_) => Future.value());
      await _storageService!.removeAllWallets();

      verify(_mockCipherService!.reset());
      verify(_mockSqliteService!.removeAllWallets());
    });
  });

  group("removeWallet", () {
    const id = "TestId";

    testWidgets('success', (tester) async {
      when(_mockCipherService!.removeKey(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(true));
      when(_mockSqliteService!.removeWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.value());
      await _storageService!.removeWallet(id);

      verify(_mockCipherService!.removeKey(id: id));
      verify(_mockSqliteService!.removeWallet(id: id));
    });
  });

  group("renameWallet", () {
    testWidgets('success', (tester) async {
      when(
        _mockSqliteService!.renameWallet(
          id: anyNamed("id"),
          name: anyNamed("name"),
        ),
      ).thenAnswer((_) => Future.value());

      await _storageService!.renameWallet(id: "Id", name: "Name");

      verify(_mockSqliteService!.renameWallet(id: "Id", name: "Name"));
    });
  });

  group("selectWallet", () {
    testWidgets('success', (tester) async {
      final walletDetails = WalletDetails(
        id: "Id",
        address: "Address",
        name: "Name",
      );
      when(
        _mockSqliteService!.selectWallet(
          id: anyNamed("id"),
        ),
      ).thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.selectWallet(id: "Id");

      verify(_mockSqliteService!.selectWallet(id: "Id"));
      expect(result, walletDetails);
    });

    testWidgets('null', (tester) async {
      when(
        _mockSqliteService!.selectWallet(
          id: anyNamed("id"),
        ),
      ).thenAnswer((_) => Future.value(null));

      final result = await _storageService!.selectWallet(id: "Id");
      expect(result, null);
    });
  });

  group("getUseBiometry", () {
    testWidgets('success', (tester) async {
      when(_mockCipherService!.getUseBiometry())
          .thenAnswer((_) => Future.value(true));

      final result = await _storageService!.getUseBiometry();
      verifyNoMoreInteractions(_mockSqliteService);
      expect(result, true);
    });
  });

  group("setUseBiometry", () {
    testWidgets('success', (tester) async {
      when(_mockCipherService!
              .setUseBiometry(useBiometry: anyNamed("useBiometry")))
          .thenAnswer((_) => Future.value(false));

      final result = await _storageService!.setUseBiometry(true);
      verifyNoMoreInteractions(_mockSqliteService);
      expect(result, false);
      verify(_mockCipherService!.setUseBiometry(useBiometry: true));
    });
  });
}
