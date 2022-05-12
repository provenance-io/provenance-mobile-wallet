import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/memory_account_storage_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';

void main() {
  test('On set coin expect selected wallet updates', () async {
    const initialCoin = Coin.mainNet;
    final service = await createService(dataCount: 2, coin: initialCoin);

    var calledUpdate = false;
    service.events.updated.listen((event) {
      calledUpdate = true;
    });

    final initial = service.events.selected.value!;
    expect(initial.coin, initialCoin);

    const updatedCoin = Coin.testNet;
    final updated =
        await service.setAccountCoin(id: initial.id, coin: updatedCoin);

    await pumpEventQueue();

    expect(updated!.coin, updatedCoin);
    expect(service.events.selected.value!.coin, updatedCoin);
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
  String? selectedWalletId,
  bool? useBiometry,
}) async {
  final datas = createDatas(dataCount, coin);
  final service = AccountService(
    storage: MemoryAccountStorageService(
      datas: datas,
      selectedWalletId: selectedWalletId,
      useBiometry: useBiometry,
    ),
  );

  await service.init();

  await pumpEventQueue();

  return service;
}

List<MemoryStorageData> createDatas(int count, Coin selectedCoin) {
  final datas = <MemoryStorageData>[];

  for (var i = 0; i < count; i++) {
    final str = i.toString();
    final seed = Mnemonic.createSeed([str]);
    final privateKeys = [
      PrivateKey.fromSeed(seed, Coin.mainNet),
      PrivateKey.fromSeed(seed, Coin.testNet),
    ];
    final selectedIndex = privateKeys.indexWhere((e) => e.coin == selectedCoin);
    assert(selectedIndex != -1, 'Unknown selected coin');

    final data = MemoryStorageData(
      AccountDetails(
        id: str,
        address: str,
        name: str,
        publicKey: str,
        coin: selectedCoin,
      ),
      privateKeys,
      selectedIndex,
    );
    datas.add(data);
  }

  return datas;
}
