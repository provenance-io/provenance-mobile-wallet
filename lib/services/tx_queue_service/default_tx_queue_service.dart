import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/extension/list_extension.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/tx_queue_service/models/sembast_gas_estimate.dart';
import 'package:provenance_wallet/services/tx_queue_service/models/sembast_scheduled_tx.dart';
import 'package:provenance_wallet/services/tx_queue_service/models/sembast_tx_signer.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service_error.dart';
import 'package:provenance_wallet/util/public_key_util.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

class DefaultQueueTxService implements TxQueueService {
  DefaultQueueTxService({
    required TransactionHandler transactionHandler,
    required MultiSigClient multiSigClient,
    required AccountService accountService,
  })  : _transactionHandler = transactionHandler,
        _multiSigClient = multiSigClient,
        _accountService = accountService {
    _db = _initDb();
  }

  final _store = StoreRef<String, Map<String, Object?>?>.main();

  final TransactionHandler _transactionHandler;
  final MultiSigClient _multiSigClient;
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
        account.coin,
      );

  @override
  Future<ScheduledTx> scheduleTx({
    required proto.TxBody txBody,
    required TransactableAccount account,
    required AccountGasEstimate gasEstimate,
  }) async {
    final db = await _db;

    final estimateModel = SembastGasEstimate(
      estimatedGas: gasEstimate.estimatedGas,
      baseFee: gasEstimate.baseFee,
      gasAdjustment: gasEstimate.gasAdjustment,
      estimatedFees: gasEstimate.estimatedFees,
    );

    ScheduledTx response;

    switch (account.kind) {
      case AccountKind.basic:
        final basicAccount = account as BasicAccount;

        final model = SembastScheduledTx(
          accountId: basicAccount.id,
          txBody: txBody,
        );

        final result = await _executeBasic(account, model);

        response = ScheduledTx(
          result: result,
        );

        break;
      case AccountKind.multi:
        final multiAccount = account as MultiTransactableAccount;

        final address = multiAccount.address;
        final signerAddress = multiAccount.linkedAccount.address;

        final fee = proto.Fee(
          amount: gasEstimate.totalFees,
          gasLimit: proto.Int64(gasEstimate.estimatedGas),
        );

        final remoteId = await _multiSigClient.createTx(
          multiSigAddress: address,
          coin: multiAccount.coin,
          signerAddress: signerAddress,
          txBody: txBody,
          fee: fee,
        );

        if (remoteId == null) {
          throw TxQueueServiceError.createTxFailed;
        } else {
          final model = SembastScheduledTx(
            accountId: account.id,
            remoteId: remoteId,
            txBody: txBody,
            gasEstimate: estimateModel,
          );

          final ref = _store.record(remoteId);
          await ref.put(db, model.toRecord());

          response = ScheduledTx(
            txId: remoteId,
          );
        }

        break;
    }

    return response;
  }

  @override
  Future<TxResult> completeTx({
    required String remoteTxId,
    required List<TxSigner> signers,
  }) async {
    TxResult result;

    final db = await _db;
    final ref = _store.record(remoteTxId);
    final rec = await ref.get(db);
    if (rec == null) {
      throw TxQueueServiceError.txNotFound;
    } else {
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

  Future<TxResult> _execute(String id) async {
    TxResult result;

    final db = await _db;

    final rec = _store.record(id);
    final data = await rec.get(db);
    if (data == null) {
      throw TxQueueServiceError.txNotFound;
    }

    final model = SembastScheduledTx.fromRecord(data);

    final account = await _accountService.getAccount(model.accountId);
    if (account == null) {
      throw TxQueueServiceError.accountNotFound;
    } else {
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

    return result;
  }

  Future<TxResult> _executeBasic(
      BasicAccount account, SembastScheduledTx model) async {
    final privateKey = await _accountService.loadKey(account.id);
    if (privateKey == null) {
      throw TxQueueServiceError.cipherKeyNotFound;
    }

    TxResult? result;

    final response = await _transactionHandler.executeTransaction(
      model.txBody,
      privateKey.defaultKey(),
      account.coin,
    );

    result = TxResult(
      body: model.txBody,
      response: response,
    );

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
      account.coin,
    );

    return TxResult(
      body: model.txBody,
      response: response,
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
