import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';

import '../dashboard/in_memory_wallet_storage_service.dart';

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
        await service.setWalletCoin(id: initial.id, coin: updatedCoin);

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
    final updated = await service.renameWallet(id: id, name: newName);

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

Future<WalletService> createService({
  int dataCount = 0,
  Coin coin = Coin.mainNet,
  String? selectedWalletId,
  bool? useBiometry,
}) async {
  final datas = createDatas(dataCount, coin);
  final service = WalletService(
    storage: InMemoryWalletStorageService(
      datas: datas,
      selectedWalletId: selectedWalletId,
      useBiometry: useBiometry,
    ),
  );

  await service.init();

  await pumpEventQueue();

  return service;
}

List<InMemoryStorageData> createDatas(int count, Coin selectedCoin) {
  final datas = <InMemoryStorageData>[];

  for (var i = 0; i < count; i++) {
    final str = i.toString();
    final seed = Mnemonic.createSeed([str]);
    final privateKeys = [
      PrivateKey.fromSeed(seed, Coin.mainNet),
      PrivateKey.fromSeed(seed, Coin.testNet),
    ];
    final selectedIndex = privateKeys.indexWhere((e) => e.coin == selectedCoin);
    assert(selectedIndex != -1, 'Unknown selected coin');

    final data = InMemoryStorageData(
      WalletDetails(
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