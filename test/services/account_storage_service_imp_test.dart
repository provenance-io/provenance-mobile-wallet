import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_imp.dart';
import 'package:provenance_wallet/services/account_service/wallet_storage_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/sqlite_account_storage_service.dart';

import 'account_storage_service_imp_test.mocks.dart';

@GenerateMocks([SqliteAccountStorageService, CipherService])
main() {
  MockSqliteAccountStorageService? _mockSqliteService;
  MockCipherService? _mockCipherService;

  AccountStorageServiceImp? _storageService;

  setUp(() {
    _mockSqliteService = MockSqliteAccountStorageService();
    _mockCipherService = MockCipherService();

    _storageService =
        AccountStorageServiceImp(_mockSqliteService!, _mockCipherService!);
  });

  group("addWallet", () {
    List<PrivateKey>? privateKeys;
    Coin? selectedCoin;
    final publicKeys = <PublicKeyData>[];
    const id = "TestId";
    final wallet = AccountDetails(
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
      when(_mockSqliteService!.addAccount(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
        selectedChainId: anyNamed("selectedChainId"),
      )).thenAnswer((_) => Future.value(wallet));

      when(_mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(true));

      final result = await _storageService!.addAccount(
        name: wallet.name,
        privateKeys: privateKeys!,
        selectedCoin: selectedCoin!,
      );

      expect(result, wallet);

      verify(_mockSqliteService!.addAccount(
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

      when(_mockSqliteService!.addAccount(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
        selectedChainId: anyNamed("selectedChainId"),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => _storageService!.addAccount(
          name: "Name",
          privateKeys: privateKeys!,
          selectedCoin: selectedCoin!,
        ),
        throwsA(exception),
      );

      verifyNoMoreInteractions(_mockCipherService);
    });

    testWidgets('error while encrypting key', (tester) async {
      when(_mockSqliteService!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(0));
      when(_mockSqliteService!.addAccount(
        name: anyNamed("name"),
        publicKeys: anyNamed("publicKeys"),
        selectedChainId: anyNamed("selectedChainId"),
      )).thenAnswer((_) => Future.value(wallet));

      when(_mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(false));

      final result = await _storageService!.addAccount(
        name: "Name",
        privateKeys: privateKeys!,
        selectedCoin: selectedCoin!,
      );

      verify(_mockSqliteService!.removeAccount(id: id));

      expect(result, isNull);
    });
  });

  group("getSelectedWallet", () {
    test("success", () async {
      final walletDetails = AccountDetails(
        id: "id1",
        address: "Address1",
        name: "Name1",
        publicKey: "PubKey",
        coin: Coin.testNet,
      );

      when(_mockSqliteService!.getSelectedAccount())
          .thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.getSelectedAccount();
      expect(result, walletDetails);
    });
  });

  group("getWallet", () {
    test("success", () async {
      final walletDetails = AccountDetails(
        id: "id1",
        address: "Address1",
        name: "Name1",
        publicKey: "PubKey",
        coin: Coin.testNet,
      );

      when(_mockSqliteService!.getAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.getAccount("walletId");
      expect(result, walletDetails);
      verify(_mockSqliteService!.getAccount(id: "walletId"));
    });
  });

  group("getWallets", () {
    test("success", () async {
      final walletDetails = [
        AccountDetails(
          id: "id1",
          address: "Address1",
          name: "Name1",
          publicKey: "PubKey",
          coin: Coin.testNet,
        ),
        AccountDetails(
          id: "id2",
          address: "Address2",
          name: "Name2",
          publicKey: "PubKey",
          coin: Coin.testNet,
        ),
      ];

      when(_mockSqliteService!.getAccounts())
          .thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.getAccounts();
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
      when(_mockSqliteService!.removeAllAccounts())
          .thenAnswer((_) => Future.value(1));
      await _storageService!.removeAllAccounts();

      verify(_mockCipherService!.reset());
      verify(_mockSqliteService!.removeAllAccounts());
    });
  });

  group("removeWallet", () {
    const id = "TestId";

    testWidgets('success', (tester) async {
      when(_mockCipherService!.removeKey(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(true));
      when(_mockSqliteService!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(1));
      await _storageService!.removeAccount(id);

      for (final coin in Coin.values) {
        final keyId = _storageService!.privateKeyId(id, coin);
        verify(_mockCipherService!.removeKey(id: keyId));
      }

      verify(_mockSqliteService!.removeAccount(id: id));
    });
  });

  group("renameWallet", () {
    testWidgets('success', (tester) async {
      when(
        _mockSqliteService!.renameAccount(
          id: anyNamed("id"),
          name: anyNamed("name"),
        ),
      ).thenAnswer((_) => Future.value());

      await _storageService!.renameAccount(id: "Id", name: "Name");

      verify(_mockSqliteService!.renameAccount(id: "Id", name: "Name"));
    });
  });

  group("selectWallet", () {
    testWidgets('success', (tester) async {
      final walletDetails = AccountDetails(
        id: "Id",
        address: "Address",
        name: "Name",
        publicKey: "PubKey",
        coin: Coin.testNet,
      );
      when(
        _mockSqliteService!.selectAccount(
          id: anyNamed("id"),
        ),
      ).thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.selectAccount(id: "Id");

      verify(_mockSqliteService!.selectAccount(id: "Id"));
      expect(result, walletDetails);
    });

    testWidgets('null', (tester) async {
      when(
        _mockSqliteService!.selectAccount(
          id: anyNamed("id"),
        ),
      ).thenAnswer((_) => Future.value(null));

      final result = await _storageService!.selectAccount(id: "Id");
      expect(result, null);
    });
  });
}
