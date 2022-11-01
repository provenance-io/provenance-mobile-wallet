import 'package:convert/convert.dart' as convert;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_imp.dart';
import 'package:provenance_wallet/services/models/account.dart';

import 'account_storage_service_imp_test.mocks.dart';

@GenerateMocks([AccountStorageServiceCore, CipherService])
main() {
  MockAccountStorageServiceCore? _mockAccountStorageServiceCore;
  MockCipherService? _mockCipherService;

  AccountStorageServiceImp? _storageService;

  PublicKey keyFromHex(String hex, Coin coin) {
    return PublicKey.fromCompressPublicHex(
        convert.hex.decoder.convert(hex), coin);
  }

  final accounts = [
    BasicAccount(
      id: "id1",
      name: "Name1",
      publicKey: PrivateKey.fromSeed(Mnemonic.createSeed(['id1']), Coin.testNet)
          .defaultKey()
          .publicKey,
    ),
    BasicAccount(
      id: "id2",
      name: "Name2",
      publicKey: PrivateKey.fromSeed(Mnemonic.createSeed(['id2']), Coin.testNet)
          .defaultKey()
          .publicKey,
    ),
  ];

  setUp(() {
    _mockAccountStorageServiceCore = MockAccountStorageServiceCore();
    _mockCipherService = MockCipherService();

    _storageService = AccountStorageServiceImp(
        _mockAccountStorageServiceCore!, _mockCipherService!);
  });

  group("addWallet", () {
    late PrivateKey privateKey;
    late PublicKeyData publicKeyData;
    const id = "TestId";

    BasicAccount firstAccount() {
      final coin = Coin.forChainId(publicKeyData.chainId);
      final publicKey = keyFromHex(publicKeyData.hex, coin);

      return BasicAccount(
        id: id,
        name: 'Test Wallet',
        publicKey: publicKey,
      );
    }

    setUp(() {
      final seed = Mnemonic.createSeed(['test']);
      privateKey = PrivateKey.fromSeed(seed, Coin.testNet);

      final publicKey = privateKey.defaultKey().publicKey;
      publicKeyData = PublicKeyData(
        hex: publicKey.compressedPublicKeyHex,
        chainId: privateKey.coin.chainId,
      );
    });

    test('success', () async {
      final account = firstAccount();

      when(_mockAccountStorageServiceCore!.addBasicAccount(
        name: anyNamed("name"),
        publicKey: anyNamed("publicKey"),
      )).thenAnswer((_) => Future.value(account));

      when(_mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(true));

      final result = await _storageService!.addAccount(
        name: account.name,
        privateKey: privateKey,
      );

      expect(result, account);

      verify(_mockAccountStorageServiceCore!.addBasicAccount(
        name: account.name,
        publicKey: publicKeyData,
      ));

      final keyId = _storageService!.privateKeyId(id, privateKey.coin);

      verify(_mockCipherService!.encryptKey(
        id: keyId,
        privateKey: privateKey.serialize(publicKeyOnly: false),
      ));
    });

    testWidgets('add wallet failure', (tester) async {
      final exception = Exception("Error");

      when(_mockAccountStorageServiceCore!.addBasicAccount(
        name: anyNamed("name"),
        publicKey: anyNamed("publicKey"),
      )).thenAnswer((_) => Future.error(exception));

      expect(
        () => _storageService!.addAccount(
          name: "Name",
          privateKey: privateKey,
        ),
        throwsA(exception),
      );

      verifyNoMoreInteractions(_mockCipherService);
    });

    testWidgets('error while encrypting key', (tester) async {
      final account = firstAccount();

      when(_mockAccountStorageServiceCore!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(0));
      when(_mockAccountStorageServiceCore!.addBasicAccount(
        name: anyNamed("name"),
        publicKey: anyNamed("publicKey"),
      )).thenAnswer((_) => Future.value(account));

      when(_mockCipherService!.encryptKey(
        id: anyNamed("id"),
        privateKey: anyNamed("privateKey"),
      )).thenAnswer((_) => Future.value(false));

      final result = await _storageService!.addAccount(
        name: "Name",
        privateKey: privateKey,
      );

      verify(_mockAccountStorageServiceCore!.removeAccount(id: id));

      expect(result, isNull);
    });
  });

  group("getSelectedWallet", () {
    test("success", () async {
      final walletDetails = accounts.first;

      when(_mockAccountStorageServiceCore!.getSelectedAccount())
          .thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.getSelectedAccount();
      expect(result, walletDetails);
    });
  });

  group("getWallet", () {
    test("success", () async {
      final walletDetails = accounts.first;

      when(_mockAccountStorageServiceCore!.getAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.getAccount("walletId");
      expect(result, walletDetails);
      verify(_mockAccountStorageServiceCore!.getAccount(id: "walletId"));
    });
  });

  group("getWallets", () {
    test("success", () async {
      when(_mockAccountStorageServiceCore!.getBasicAccounts())
          .thenAnswer((_) => Future.value(accounts));

      final result = await _storageService!.getBasicAccounts();
      expect(result, accounts);
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
      verifyNoMoreInteractions(_mockAccountStorageServiceCore);
    });
  });

  group("removeAllWallets", () {
    testWidgets('success', (tester) async {
      when(_mockCipherService!.resetKeys())
          .thenAnswer((_) => Future.value(true));
      when(_mockAccountStorageServiceCore!.removeAllAccounts())
          .thenAnswer((_) => Future.value(1));
      await _storageService!.removeAllAccounts();

      verify(_mockCipherService!.resetKeys());
      verify(_mockAccountStorageServiceCore!.removeAllAccounts());
    });
  });

  group("removeWallet", () {
    const id = "TestId";

    testWidgets('success', (tester) async {
      when(_mockCipherService!.removeKey(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(true));
      when(_mockAccountStorageServiceCore!.removeAccount(id: anyNamed("id")))
          .thenAnswer((_) => Future.value(1));
      await _storageService!.removeAccount(id);

      for (final coin in Coin.values) {
        final keyId = _storageService!.privateKeyId(id, coin);
        verify(_mockCipherService!.removeKey(id: keyId));
      }

      verify(_mockAccountStorageServiceCore!.removeAccount(id: id));
    });
  });

  group("renameWallet", () {
    testWidgets('success', (tester) async {
      when(
        _mockAccountStorageServiceCore!.renameAccount(
          id: anyNamed("id"),
          name: anyNamed("name"),
        ),
      ).thenAnswer((_) => Future.value());

      await _storageService!.renameAccount(id: "Id", name: "Name");

      verify(_mockAccountStorageServiceCore!
          .renameAccount(id: "Id", name: "Name"));
    });
  });

  group("selectWallet", () {
    testWidgets('success', (tester) async {
      final walletDetails = accounts.first;

      when(
        _mockAccountStorageServiceCore!.selectAccount(
          id: anyNamed("id"),
        ),
      ).thenAnswer((_) => Future.value(walletDetails));

      final result = await _storageService!.selectAccount(id: "Id");

      verify(_mockAccountStorageServiceCore!.selectAccount(id: "Id"));
      expect(result, walletDetails);
    });

    testWidgets('null', (tester) async {
      when(
        _mockAccountStorageServiceCore!.selectAccount(
          id: anyNamed("id"),
        ),
      ).thenAnswer((_) => Future.value(null));

      final result = await _storageService!.selectAccount(id: "Id");
      expect(result, null);
    });
  });
}
