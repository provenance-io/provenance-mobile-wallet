import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_blockchain_wallet/chain_id.dart';
import 'package:provenance_blockchain_wallet/services/models/wallet_details.dart';
import 'package:provenance_blockchain_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_storage_service.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_storage_service_imp.dart';
import 'package:provenance_dart/wallet.dart';

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
    List<PrivateKey>? privateKeys;
    Coin? selectedCoin;
    final publicKeys = <PublicKeyData>[];
    const id = "TestId";
    final wallet = WalletDetails(
      id: id,
      address: 'address',
      name: 'Test Wallet',
      publicKey: "",
      coin: Coin.testNet,
    );

    setUp(() {
      final seed = Mnemonic.createSeed(['test']);
      privateKeys = [
        PrivateKey.fromSeed(seed, Coin.testNet),
        PrivateKey.fromSeed(seed, Coin.mainNet),
      ];
      selectedCoin = Coin.testNet;

      publicKeys.clear();
      for (final privateKey in privateKeys!) {
        final publicKey = privateKey.defaultKey().publicKey;
        final publicKeyData = PublicKeyData(
          address: publicKey.address,
          hex: publicKey.compressedPublicKeyHex,
          chainId: ChainId.forCoin(privateKey.coin),
        );
        publicKeys.add(publicKeyData);
      }
    });

    test('success', () async {
      when(_mockSqliteService!.addWallet(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
        selectedChainId: anyNamed("selectedChainId"),
      )).thenAnswer((_) => Future.value(wallet));

      when(_mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(true));

      final result = await _storageService!.addWallet(
        name: wallet.name,
        privateKeys: privateKeys!,
        selectedCoin: selectedCoin!,
      );

      expect(result, wallet);

      verify(_mockSqliteService!.addWallet(
        name: wallet.name,
        publicKeys: publicKeys,
        selectedChainId: ChainId.forCoin(selectedCoin!),
      ));

      for (final privateKey in privateKeys!) {
        final keyId = _storageService!.privateKeyId(id, privateKey.coin);

        verify(_mockCipherService!.encryptKey(
          id: keyId,
          privateKey: privateKey.serialize(publicKeyOnly: false),
        ));
      }
    });

    testWidgets('add wallet failure', (tester) async {
      final exception = Exception("Error");

      when(_mockSqliteService!.addWallet(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
        selectedChainId: anyNamed("selectedChainId"),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => _storageService!.addWallet(
          name: "Name",
          privateKeys: privateKeys!,
          selectedCoin: selectedCoin!,
        ),
        throwsA(exception),
      );

      verifyNoMoreInteractions(_mockCipherService);
    });

    testWidgets('error while encrypting key', (tester) async {
      when(_mockSqliteService!.removeWallet(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(0));
      when(_mockSqliteService!.addWallet(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
        selectedChainId: anyNamed("selectedChainId"),
      )).thenAnswer((_) => Future.value(wallet));

      when(_mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(false));

      final result = await _storageService!.addWallet(
        name: "Name",
        privateKeys: privateKeys!,
        selectedCoin: selectedCoin!,
      );

      verify(_mockSqliteService!.removeWallet(id: id));

      expect(result, isNull);
    });
  });

  group("getSelectedWallet", () {
    test("success", () async {
      final walletDetails = WalletDetails(
        id: "id1",
        address: "Address1",
        name: "Name1",
        publicKey: "PubKey",
        coin: Coin.testNet,
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
        publicKey: "PubKey",
        coin: Coin.testNet,
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
          publicKey: "PubKey",
          coin: Coin.testNet,
        ),
        WalletDetails(
          id: "id2",
          address: "Address2",
          name: "Name2",
          publicKey: "PubKey",
          coin: Coin.testNet,
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
    const coin = Coin.testNet;

    testWidgets('success', (tester) async {
      when(_mockCipherService!.decryptKey(
        id: anyNamed("id"),
      )).thenAnswer((_) => Future.value(bip32Serialized));

      final keyId = _storageService!.privateKeyId(id, coin);
      final privateKey = await _storageService!.loadKey(id, coin);
      expect(privateKey!.rawHex, PrivateKey.fromBip32(bip32Serialized).rawHex);
      verify(_mockCipherService!.decryptKey(id: keyId));
      verifyNoMoreInteractions(_mockSqliteService);
    });
  });

  group("removeAllWallets", () {
    testWidgets('success', (tester) async {
      when(_mockCipherService!.reset()).thenAnswer((_) => Future.value(true));
      when(_mockSqliteService!.removeAllWallets())
          .thenAnswer((_) => Future.value(1));
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
          .thenAnswer((_) => Future.value(1));
      await _storageService!.removeWallet(id);

      for (final coin in Coin.values) {
        final keyId = _storageService!.privateKeyId(id, coin);
        verify(_mockCipherService!.removeKey(id: keyId));
      }

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
        publicKey: "PubKey",
        coin: Coin.testNet,
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
}
