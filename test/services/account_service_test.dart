import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_imp.dart';
import 'package:provenance_wallet/services/account_service/sembast_account_storage_service_v2.dart';
import 'package:sembast/sembast_memory.dart';

import '../screens/receive_flow/receive/receive_screen_test.dart';

final dbPath = path.join(sembastInMemoryDatabasePath, 'account.db');

void main() {
  tearDown(() async {
    await get.reset(dispose: true);
  });

  test('On rename selected wallet expect selected wallet updates', () async {
    final service = await createService(dataCount: 2);

    var calledUpdate = false;
    service.events.updated.listen((event) {
      calledUpdate = true;
    });

    final id = service.events.selected.value!.id;
    const newName = 'new name';
    final updated = await service.renameAccount(id: id, name: newName);

    await pumpEventQueue();

    expect(updated!.name, newName);
    expect(service.events.selected.value!.name, newName);
    expect(calledUpdate, isTrue);
  });

  test('On init expect wallet is selected', () async {
    final service = await createService(dataCount: 2);

    expect(service.events.selected.valueOrNull, isNotNull);
  });
}

Future<AccountService> createService({
  int dataCount = 0,
  Coin coin = Coin.mainNet,
}) async {
  final export = await createDatabaseExport(
    dataCount: dataCount,
    coin: coin,
  );

  final serviceCore = SembastAccountStorageServiceV2(
    factory: newDatabaseFactoryMemory(),
    dbPath: dbPath,
    import: export,
  );
  final cipherService = MemoryCipherService();

  final service = AccountService(
    storage: AccountStorageServiceImp(
      serviceCore,
      cipherService,
    ),
  );

  final accounts = await service.getAccounts();
  expect(accounts.length, dataCount);

  get.registerSingleton(serviceCore,
      dispose: (SembastAccountStorageServiceV2 serviceCore) {
    return serviceCore.deleteDatabase();
  });

  get.registerSingleton(service);

  await pumpEventQueue();

  return service;
}

Future<Map<String, Object?>> createDatabaseExport({
  int dataCount = 0,
  Coin coin = Coin.mainNet,
}) async {
  final serviceCore = SembastAccountStorageServiceV2(
    factory: newDatabaseFactoryMemory(),
    dbPath: dbPath,
  );
  final cipherService = MemoryCipherService();

  final service = AccountService(
    storage: AccountStorageServiceImp(
      serviceCore,
      cipherService,
    ),
  );

  for (var i = 0; i < dataCount; i++) {
    await service.addAccount(
      phrase: [
        '$i',
      ],
      name: '$i',
      coin: coin,
    );
  }

  await service.selectFirstAccount();

  final data = await serviceCore.exportDatabase();

  return data;
}
