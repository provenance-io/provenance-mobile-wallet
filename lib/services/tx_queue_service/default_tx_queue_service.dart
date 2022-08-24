import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/extension/list_extension.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/models/sembast_gas_estimate.dart';
import 'package:provenance_wallet/services/tx_queue_service/models/sembast_scheduled_tx.dart';
import 'package:provenance_wallet/services/tx_queue_service/models/sembast_tx_signer.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/util/public_key_util.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

class DefaultQueueTxService implements TxQueueService {
  DefaultQueueTxService({
    required TransactionHandler transactionHandler,
    required CipherService cipherService,
    required MultiSigService multiSigService,
    required AccountService accountService,
  })  : _transactionHandler = transactionHandler,
        _cipherService = cipherService,
        _multiSigService = multiSigService,
        _accountService = accountService {
    _db = _initDb();
  }

  final _store = StoreRef<String, Map<String, Object?>?>.main();

  final TransactionHandler _transactionHandler;
  final CipherService _cipherService;
  final MultiSigService _multiSigService;
  final AccountService _accountService;

  late final Future<Database> _db;

  @override
  Future<AccountGasEstimate> estimateGas({
    required proto.TxBody txBody,
    required TransactableAccount account,
  }) =>
      _transactionHandler.estimateGas(
        txBody,
        [
          account.publicKey,
        ],
      );

  @override
  Future<ScheduleTxResponse> scheduleTx({
    required proto.TxBody txBody,
    required TransactableAccount account,
    AccountGasEstimate? gasEstimate,
  }) async {
    final db = await _db;

    SembastGasEstimate? estimateModel;
    if (gasEstimate != null) {
      estimateModel = SembastGasEstimate(
        estimatedGas: gasEstimate.estimatedGas,
        baseFee: gasEstimate.baseFee,
        gasAdjustment: gasEstimate.gasAdjustment,
        estimatedFees: gasEstimate.estimatedFees,
      );
    }

    String? id;
    TxResult? result;

    switch (account.kind) {
      case AccountKind.basic:
        final basicAccount = account as BasicAccount;

        final model = SembastScheduledTx(
          accountId: basicAccount.id,
          txBody: txBody,
        );

        result = await _executeBasic(account, model);

        break;
      case AccountKind.multi:
        final multiAccount = account as MultiTransactableAccount;

        final address = multiAccount.address;
        final signerAddress = multiAccount.linkedAccount.address;

        final remoteId = await _multiSigService.createTx(
          multiSigAddress: address,
          signerAddress: signerAddress,
          txBody: txBody,
        );
        if (remoteId != null) {
          final model = SembastScheduledTx(
            accountId: account.id,
            remoteId: remoteId,
            txBody: txBody,
            gasEstimate: estimateModel,
          );

          final ref = _store.record(remoteId);
          await ref.put(db, model.toRecord());
        }

        break;
    }

    // TODO-Roy: handle network failure
    //   return null?
    //   return failed response?

    return ScheduleTxResponse(
      txId: id,
      result: result,
    );
  }

  @override
  Future<TxResult?> completeTx({
    required String remoteTxId,
    required List<TxSigner> signers,
  }) async {
    TxResult? result;

    final db = await _db;
    final ref = _store.record(remoteTxId);
    final rec = await ref.get(db);
    if (rec != null) {
      final model = SembastScheduledTx.fromRecord(rec).copyWith(
        signers: signers
            .map(
              (e) => SembastTxSigner(
                publicKey: e.publicKey,
                signature: e.signature,
                signerOrder: e.signerOrder,
              ),
            )
            .toList(),
      );

      await ref.update(
        db,
        model.toRecord(),
      );

      result = await _execute(remoteTxId);
    }

    return result;
  }

  Future<TxResult?> _execute(String id) async {
    TxResult? result;

    final db = await _db;

    final rec = _store.record(id);
    final data = await rec.get(db);
    if (data != null) {
      final model = SembastScheduledTx.fromRecord(data);

      final account = await _accountService.getAccount(model.accountId);
      if (account != null) {
        switch (account.kind) {
          case AccountKind.basic:
            result = await _executeBasic(account as BasicAccount, model);
            break;
          case AccountKind.multi:
            result =
                await _executeMulti(account as MultiTransactableAccount, model);
            break;
        }

        await rec.delete(db);
      }
    }

    return result;
  }

  Future<TxResult?> _executeBasic(
      BasicAccount account, SembastScheduledTx model) async {
    final serialized = await _cipherService.decryptKey(
      id: account.id,
    );

    TxResult? result;

    if (serialized != null) {
      final privateKey = PrivateKey.fromBip32(serialized);
      final response = await _transactionHandler.executeTransaction(
        model.txBody,
        privateKey.defaultKey(),
      );

      result = TxResult(
        body: model.txBody,
        response: response.txResponse,
      );
    }

    return result;
  }

  Future<TxResult> _executeMulti(
      MultiTransactableAccount account, SembastScheduledTx model) async {
    final coin = account.coin;
    final threshold = account.signaturesRequired;

    final publicKeys = <PublicKey>[];
    final sigLookup = <String, List<int>>{};

    final orderedSigners = model.signers!.toList()
      ..sortAscendingBy((e) => e.signerOrder);

    for (final signer in orderedSigners) {
      final publicKey = publicKeyFromCompressedHex(signer.publicKey, coin);
      publicKeys.add(publicKey);

      sigLookup[publicKey.address] = utf8.encode(signer.signature);
    }

    final aminoKey = AminoPrivKey(
      threshold: threshold,
      pubKeys: publicKeys,
      coin: coin,
      sigLookup: sigLookup,
    );

    final response = await _transactionHandler.executeTransaction(
      model.txBody,
      aminoKey,
    );

    return TxResult(
      body: model.txBody,
      response: response.txResponse,
    );
  }

  Future<Database> _initDb() async {
    final directory = await getApplicationDocumentsDirectory();
    await directory.create(recursive: true);

    // final factory = databaseFactoryIo;
    final factory = databaseFactoryMemory;

    final path = p.join(directory.path, 'tx.db');

    final db = await factory.openDatabase(
      path,
      version: 1,
    );

    return db;
  }
}
