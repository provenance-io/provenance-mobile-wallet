import 'package:flutter_test/flutter_test.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_imp.dart';
import 'package:provenance_wallet/services/account_service/sembast_account_storage_service.dart';
import 'package:sembast/sembast_memory.dart';

import '../screens/receive_flow/receive/receive_screen_test.dart';

void main() {
  tearDown(() async {
    await get<SembastAccountStorageService>().deleteDatabase();
    await get.reset(dispose: true);
  });

  test('On set coin expect selected wallet updates', () async {
    const initialCoin = Coin.mainNet;
    final service = await createService(dataCount: 2, coin: initialCoin);

    var calledUpdate = false;
    service.events.updated.listen((event) {
      calledUpdate = true;
    });

    final initial = service.events.selected.value!;
    expect(initial.publicKey!.coin, initialCoin);

    const updatedCoin = Coin.testNet;
    final updated =
        await service.setAccountCoin(id: initial.id, coin: updatedCoin);

    await pumpEventQueue();

    expect(updated!.publicKey!.coin, updatedCoin);
    expect(service.events.selected.value!.publicKey!.coin, updatedCoin);
    expect(calledUpdate, isTrue);
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
  bool? useBiometry,
}) async {
  final serviceCore = SembastAccountStorageService(
    factory: databaseFactoryMemory,
    directory: sembastInMemoryDatabasePath,
  );
  final cipherService = MemoryCipherService();
  final service = AccountService(
    storage: AccountStorageServiceImp(
      serviceCore,
      cipherService,
    ),
  );

  get.registerSingleton(serviceCore);
  get.registerSingleton(service);

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

  await pumpEventQueue();

  return service;
}
