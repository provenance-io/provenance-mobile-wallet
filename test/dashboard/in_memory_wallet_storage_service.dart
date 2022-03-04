import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service.dart';
import 'package:uuid/uuid.dart';

class InMemoryStorageData {
  InMemoryStorageData(this.details, this.key);

  final WalletDetails details;
  final PrivateKey key;
}

class InMemoryWalletStorageService implements WalletStorageService {
  InMemoryWalletStorageService({
    List<InMemoryStorageData>? datas,
    String? selectedWalletId,
    bool? useBiometry,
  })  : _datas = datas ?? [],
        _selectedId = selectedWalletId,
        _useBiometry = useBiometry ?? false;

  String? _selectedId;
  bool _useBiometry;
  final List<InMemoryStorageData> _datas;

  @override
  Future<WalletDetails?> addWallet({
    required String name,
    required PrivateKey privateKey,
    required bool useBiometry,
  }) async {
    final id = Uuid().v1().toString();
    final publicKey = privateKey.defaultKey().publicKey;

    final details = WalletDetails(
      id: id,
      address: publicKey.address,
      name: name,
    );

    _datas.add(InMemoryStorageData(details, privateKey));

    return details;
  }

  @override
  Future<WalletDetails?> getSelectedWallet() async {
    final id = _selectedId;
    if (id == null) {
      return null;
    }

    return getWallet(id);
  }

  @override
  Future<bool> getUseBiometry() async {
    return _useBiometry;
  }

  @override
  Future<WalletDetails?> getWallet(String id) async {
    WalletDetails? result;

    for (final data in _datas) {
      if (data.details.id == id) {
        result = data.details;
        break;
      }
    }

    return result;
  }

  @override
  Future<List<WalletDetails>> getWallets() async {
    return _datas.map((e) => e.details).toList();
  }

  @override
  Future<PrivateKey?> loadKey(String id) async {
    PrivateKey? result;

    for (final data in _datas) {
      if (data.details.id == id) {
        result = data.key;
      }
    }

    return result;
  }

  @override
  Future<bool> removeAllWallets() async {
    _datas.clear();

    return true;
  }

  @override
  Future<bool> removeWallet(String id) async {
    final length = _datas.length;
    _datas.removeWhere((e) => e.details.id == id);

    return _datas.length != length;
  }

  @override
  Future<WalletDetails?> renameWallet({
    required String id,
    required String name,
  }) async {
    WalletDetails? result;

    final index = _datas.indexWhere((e) => e.details.id == id);
    if (index != -1) {
      final old = _datas[index];
      final renamed = WalletDetails(
        id: old.details.id,
        address: old.details.address,
        name: name,
      );
      _datas[index] = InMemoryStorageData(renamed, old.key);
      result = renamed;
    }

    return result;
  }

  @override
  Future<WalletDetails?> selectWallet({String? id}) async {
    WalletDetails? result;

    if (id == null && _datas.isNotEmpty) {
      final first = _datas.first.details;
      _selectedId = first.id;

      return first;
    }

    for (final data in _datas) {
      if (data.details.id == id) {
        _selectedId = data.details.id;
        result = data.details;
        break;
      }
    }

    return result;
  }

  @override
  Future<bool> setUseBiometry(bool useBiometry) async {
    _useBiometry = useBiometry;

    return true;
  }
}
