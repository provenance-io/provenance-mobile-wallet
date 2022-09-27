import 'dart:async';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart' as convert;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signature.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/models/sembast_gas_estimate.dart';
import 'package:provenance_wallet/services/tx_queue_service/models/sembast_scheduled_tx.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service_error.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

import 'models/service_tx_response.dart';

class DefaultQueueTxService implements TxQueueService {
  DefaultQueueTxService({
    required TransactionHandler transactionHandler,
    required MultiSigService multiSigService,
    required AccountService accountService,
  })  : _transactionHandler = transactionHandler,
        _multiSigService = multiSigService,
        _accountService = accountService {
    _db = _initDb();
  }

  final _store = StoreRef<String, Map<String, Object?>?>.main();

  final _response = PublishSubject<ServiceTxResponse>();

  final TransactionHandler _transactionHandler;
  final MultiSigService _multiSigService;
  final AccountService _accountService;

  late final Future<Database> _db;

  @override
  Stream<ServiceTxResponse> get response => _response;

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

        final remoteId = await _multiSigService.createTx(
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
    required String txUuid,
  }) async {
    final item =
        _multiSigService.items.firstWhereOrNull((e) => e.txUuid == txUuid);
    if (item == null) {
      throw TxQueueServiceError.txNotFound;
    }

    final multiSigAddress = item.multiSigAddress;

    final accounts = await _accountService.getTransactableAccounts();
    final multiSigAccount =
        accounts.firstWhereOrNull((e) => e.address == multiSigAddress)
            as MultiTransactableAccount?;
    if (multiSigAccount == null) {
      throw TxQueueServiceError.accountNotFound;
    }

    final coin = multiSigAccount.coin;
    final signerAccount = multiSigAccount.linkedAccount;

    final pbClient = await get<ProtobuffClientInjector>().call(coin);

    final authBytes = await _sign(
      pbClient: pbClient,
      multiSigAddress: multiSigAddress,
      signerAccountId: signerAccount.id,
      txBody: item.txBody,
      fee: item.fee,
    );

    final unorderedSignatures = <String, List<int>>{
      signerAccount.address: authBytes,
    };

    for (final signature in item.signatures ?? <MultiSigSignature>[]) {
      unorderedSignatures[signature.signerAddress] =
          convert.hex.decode(signature.signatureHex);
    }

    final sigLookup = <String, List<int>>{};
    for (final publicKey in multiSigAccount.publicKey.publicKeys) {
      final address = publicKey.address;
      final sig = unorderedSignatures[address];
      if (sig != null) {
        sigLookup[address] = sig;
      }
    }

    final privateKey = AminoPrivKey(
      threshold: multiSigAccount.signaturesRequired,
      pubKeys: multiSigAccount.publicKey.publicKeys,
      coin: coin,
      sigLookup: sigLookup,
    );

    final responsePair = await pbClient.broadcastTransaction(
      item.txBody,
      [
        privateKey,
      ],
      item.fee,
    );

    // TODO-Roy: if is wallet connect, send update to wallet connect
    // Probably move multi-sig broadcast somewhere else and reference it both
    // here and in wallet connect delegate

    final txResponse = responsePair.txResponse;

    await _multiSigService.finalizeTx(
      signerAddress: signerAccount.address,
      txUuid: txUuid,
      response: responsePair.txResponse,
      coin: coin,
    );

    _response.add(
      ServiceTxResponse(
        code: txResponse.code,
        message: txResponse.rawLog,
        // gasUsed: response.gasUsed.toInt(),
        // gasWanted: response.gasWanted.toInt(),
        // height: response.height.toInt(),
        txHash: txResponse.txhash,
        fees: item.fee.amount,
        codespace: txResponse.codespace,
      ),
    );

    return TxResult(
      body: item.txBody,
      response: responsePair,
    );
  }

  @override
  Future<bool> signTx({
    required String txUuid,
    required String signerAddress,
    required String multiSigAddress,
    required proto.TxBody txBody,
    required proto.Fee fee,
  }) async {
    final accounts = await _accountService.getTransactableAccounts();
    final signerAccount =
        accounts.firstWhereOrNull((e) => e.address == signerAddress);
    if (signerAccount == null) {
      throw TxQueueServiceError.accountNotFound;
    }

    final coin = signerAccount.coin;
    final pbClient =
        await get<ProtobuffClientInjector>().call(signerAccount.coin);

    final authBytes = await _sign(
      pbClient: pbClient,
      multiSigAddress: multiSigAddress,
      signerAccountId: signerAccount.id,
      txBody: txBody,
      fee: fee,
    );

    final signatureBytes = convert.hex.encode(authBytes);

    final success = await _multiSigService.signTx(
      signerAddress: signerAccount.address,
      coin: coin,
      txUuid: txUuid,
      signatureBytes: signatureBytes,
    );

    return success;
  }

  Future<List<int>> _sign({
    required proto.PbClient pbClient,
    required String multiSigAddress,
    required String signerAccountId,
    required proto.TxBody txBody,
    required proto.Fee fee,
  }) async {
    final signerRootPk = await _accountService.loadKey(signerAccountId);

    final signerPk = signerRootPk!.defaultKey();

    final multiSigBaseAccount = await pbClient.getBaseAccount(multiSigAddress);

    final authBytes = pbClient.generateMultiSigAuthorization(
      signerPk,
      txBody,
      fee,
      multiSigBaseAccount,
    );

    return authBytes;
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
