import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/sembast_account_storage_service_v1.dart';
import 'package:provenance_wallet/services/account_service/sembast_account_storage_service_v2.dart';
import 'package:provenance_wallet/services/account_service/version_data.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

final dbPath = p.join(sembastInMemoryDatabasePath, 'account.db');

void main() {
  setUp(() async {
    await databaseFactoryIo.deleteDatabase(dbPath);
  });

  test('V1 account migrates to V2', () async {
    // ignore: deprecated_member_use_from_same_package
    final storageV1 = SembastAccountStorageServiceV1(
      factory: databaseFactoryMemory,
      dbPath: dbPath,
    );

    final seed = Mnemonic.createSeed(['one two']);

    final publicKeysByCoin = Coin.values
        .map((e) => PrivateKey.fromSeed(seed, e).defaultKey().publicKey)
        .toList()
        .asMap()
        .map((key, value) => MapEntry(value.coin, value));

    final publicKeyDatas = publicKeysByCoin.values
        .map(
          (e) => PublicKeyData(
            hex: e.compressedPublicKeyHex,
            chainId: ChainId.forCoin(e.coin),
          ),
        )
        .toList();

    final accountV1 = await storageV1.addBasicAccount(
      name: 'one',
      publicKeys: publicKeyDatas,
      selectedChainId: ChainId.mainNet,
    );

    expect(accountV1, isNotNull);

    await storageV1.close();

    final storageV2 = SembastAccountStorageServiceV2(
      factory: databaseFactoryMemory,
      dbPath: dbPath,
    );

    expectLater(
      storageV2.versionChanged,
      emits(
        VersionData(
          oldVersion: 1,
          newVersion: 2,
        ),
      ),
    );

    final accountV2 = await storageV2.getAccount(id: accountV1!.id);

    expect(accountV2, isNotNull);
    expect(accountV2!.name, accountV1.name);
    expect(accountV2.address, publicKeysByCoin[Coin.mainNet]!.address);
  });
}
