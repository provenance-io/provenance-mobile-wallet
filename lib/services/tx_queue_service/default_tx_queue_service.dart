import 'dart:async';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart' as convert;
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service_error.dart';
import 'package:provenance_wallet/util/fee_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class DefaultQueueTxService implements TxQueueService {
  DefaultQueueTxService({
    required TransactionHandler transactionHandler,
    required MultiSigService multiSigService,
    required AccountService accountService,
  })  : _transactionHandler = transactionHandler,
        _multiSigService = multiSigService,
        _accountService = accountService;

  final _response = PublishSubject<TxResult>();

  final TransactionHandler _transactionHandler;
  final MultiSigService _multiSigService;
  final AccountService _accountService;

  @override
  Stream<TxResult> get response => _response;

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
  Future<QueuedTx> scheduleTx({
    required proto.TxBody txBody,
    required TransactableAccount account,
    required AccountGasEstimate gasEstimate,
  }) async {
    QueuedTx queuedTx;

    switch (account.kind) {
      case AccountKind.basic:
        final basicAccount = account as BasicAccount;

        final result = await _executeBasic(basicAccount, txBody, gasEstimate);

        queuedTx = ExecutedTx(
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
          queuedTx = ScheduledTx(
            txId: remoteId,
          );
        }

        break;
    }

    return queuedTx;
  }

  @override
  Future<TxResult> completeTx({
    required String txId,
  }) async {
    final item =
        _multiSigService.items.firstWhereOrNull((e) => e.txUuid == txId);
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

    final signaturesByAddress = <String, List<int>>{
      signerAccount.address: authBytes,
    };

    for (final signature in item.signatures) {
      final signatureHex = signature.signatureHex;
      if (signatureHex != null) {
        signaturesByAddress[signature.signerAddress] =
            convert.hex.decode(signatureHex);
      }
    }

    final privateKey = AminoPrivKey(
      threshold: multiSigAccount.signaturesRequired,
      pubKeys: multiSigAccount.publicKey.publicKeys,
      coin: coin,
      sigLookup: signaturesByAddress,
    );

    final responsePair = await pbClient.broadcastTransaction(
      item.txBody,
      [
        privateKey,
      ],
      item.fee,
      proto.BroadcastMode.BROADCAST_MODE_BLOCK,
    );

    await _multiSigService.updateTxResult(
      signerAddress: signerAccount.address,
      txUuid: txId,
      response: responsePair.txResponse,
      coin: coin,
    );

    final result = TxResult(
      body: item.txBody,
      response: responsePair,
      fee: item.fee,
      txId: txId,
    );

    _response.add(result);

    return result;
  }

  @override
  Future<bool> signTx({
    required String txId,
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
      txUuid: txId,
      signatureBytes: signatureBytes,
    );

    return success;
  }

  @override
  Future<bool> declineTx({
    required String signerAddress,
    required String txId,
    required Coin coin,
  }) async {
    final success = await _multiSigService.declineTx(
      signerAddress: signerAddress,
      coin: coin,
      txUuid: txId,
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

    final signerPk = signerRootPk.defaultKey();

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
    BasicAccount account,
    proto.TxBody txBody,
    AccountGasEstimate gasEstimate,
  ) async {
    final privateKey = await _accountService.loadKey(account.id);

    TxResult? result;

    final response = await _transactionHandler.executeTransaction(
      txBody,
      privateKey.defaultKey(),
      account.coin,
      gasEstimate,
    );

    result = TxResult(
      body: txBody,
      response: response,
      fee: toFee(gasEstimate),
    );

    return result;
  }
}
