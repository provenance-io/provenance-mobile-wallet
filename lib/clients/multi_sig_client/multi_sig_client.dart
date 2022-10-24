import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_create_request_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_create_response_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_create_tx_request_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_create_tx_response_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_created_tx_request_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_get_account_by_invite_response_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_get_accounts_response_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_pending_tx_request_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_register_request_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_register_response_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_sign_tx_request_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_status.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_tx_body_bytes_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_tx_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_update_tx_request_dto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_pending_tx.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_register_result.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signature.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_update_result.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/public_key_util.dart';

enum MultiSigInviteStatus {
  pending,
  ready,
  rejected,
}

class MultiSigCosignerResponse {
  MultiSigCosignerResponse({
    required this.status,
  });

  final MultiSigInviteStatus status;
}

class MultiSigClient with ClientCoinMixin {
  static const _basePath = '/service-mobile-wallet/external/api/v1/multisig';

  Future<MultiSigRemoteAccount?> create({
    required String name,
    required int cosignerCount,
    required int threshold,
    required PublicKey publicKey,
  }) async {
    final numOfAdditionalSigners = cosignerCount - 1;
    final coin = publicKey.coin;
    final chainId = ChainId.forCoin(coin);

    final body = MultiSigCreateRequestDto(
      name: name,
      publicKey: publicKey.compressedPublicKeyHex,
      address: publicKey.address,
      numOfAdditionalSigners: numOfAdditionalSigners,
      threshold: threshold,
      chainId: chainId,
    );

    final client = await getClient(coin);
    const path = '$_basePath/create';
    final response = await client.post(
      path,
      body: body,
      converter: (json) => MultiSigCreateResponseDto.fromJson(json),
    );

    MultiSigRemoteAccount? invite;

    final data = response.data;
    if (data != null) {
      invite = MultiSigRemoteAccount(
        remoteId: data.walletUuid,
        name: data.name,
        coin: coin,
        signers: data.signers
            .map(
              (e) => _toMultiSigSigner(
                publicKeyHex: e.publicKey,
                inviteUuid: e.inviteUuid,
                coin: coin,
                signerOrder: e.signerOrder,
              ),
            )
            .toList(),
        signersRequired: data.threshold,
      );
    }

    return invite;
  }

  Future<MultiSigRegisterResult?> register({
    required String inviteId,
    required PublicKey publicKey,
  }) async {
    final client = await getClient(publicKey.coin);
    const path = '$_basePath/register';

    final body = MultiSigRegisterRequestDto(
      inviteUuid: inviteId,
      publicKey: publicKey.compressedPublicKeyHex,
      address: publicKey.address,
    );

    final response = await client.post(
      path,
      body: body,
      converter: (json) => MultiSigRegisterResponseDto.fromJson(json),
    );

    MultiSigSigner? signer;

    final data = response.data;
    if (data != null) {
      signer = _toMultiSigSigner(
        publicKeyHex: data.publicKey,
        coin: publicKey.coin,
        inviteUuid: data.inviteUuid,
        signerOrder: data.signerOrder,
      );
    }

    final error = response.error?.message;

    return MultiSigRegisterResult(
      signer: signer,
      error: error,
    );
  }

  Future<List<MultiSigRemoteAccount>?> getAccounts({
    required String address,
    required Coin coin,
  }) async {
    final client = await getClient(coin);
    final path = '$_basePath/by-address/$address';

    List<MultiSigRemoteAccount>? accounts;

    final response = await client.get(
      path,
      listConverter: (json) {
        if (json is String) {
          return <MultiSigGetAccountsResponseDto>[];
        }

        return json
            .map((e) => MultiSigGetAccountsResponseDto.fromJson(e))
            .toList();
      },
    );

    final data = response.data;
    if (data != null) {
      accounts = data
          .map(
            (e) => MultiSigRemoteAccount(
              remoteId: e.walletUuid,
              name: e.name,
              coin: coin,
              signers: e.signers
                  .map(
                    (e) => _toMultiSigSigner(
                      publicKeyHex: e.publicKey,
                      inviteUuid: e.inviteUuid,
                      coin: coin,
                      signerOrder: e.signerOrder,
                    ),
                  )
                  .toList(),
              signersRequired: e.threshold,
              address: e.address,
            ),
          )
          .toList();
    }

    return accounts;
  }

  Future<MultiSigRemoteAccount?> getAccount({
    required String remoteId,
    required String signerAddress,
    required Coin coin,
  }) async {
    final accounts = await getAccounts(
      address: signerAddress,
      coin: coin,
    );

    MultiSigRemoteAccount? account;

    if (accounts != null) {
      account = accounts.firstWhereOrNull((e) => e.remoteId == remoteId);
    }

    return account;
  }

  Future<MultiSigRemoteAccount?> getAccountByInvite({
    required String inviteId,
    required Coin coin,
  }) async {
    final client = await getClient(coin);
    final path = '$_basePath/by-invite/$inviteId';

    MultiSigRemoteAccount? account;

    final response = await client.get(
      path,
      converter: (json) => MultiSigGetAccountByInviteResponseDto.fromJson(json),
    );

    final data = response.data;
    if (data != null) {
      account = MultiSigRemoteAccount(
        remoteId: data.walletUuid,
        name: data.name,
        coin: coin,
        signers: data.signers
            .map((e) => _toMultiSigSigner(
                  publicKeyHex: e.publicKey,
                  inviteUuid: e.inviteUuid,
                  coin: coin,
                  signerOrder: e.signerOrder,
                ))
            .toList(),
        signersRequired: data.threshold,
        address: data.address,
      );
    }

    return account;
  }

  Future<String?> createTx({
    required String multiSigAddress,
    required String signerAddress,
    required Coin coin,
    required proto.TxBody txBody,
    required proto.Fee fee,
  }) async {
    final client = await getClient(coin);
    const path = '$_basePath/tx/create';

    final txBodyBytes = MultiSigTxBodyBytesDto(
      txBody: txBody,
      fee: fee,
    );

    final request = MultiSigCreateTxRequestDto(
      multiSigAddress: multiSigAddress,
      signerAddress: signerAddress,
      txBodyBytes: jsonEncode(txBodyBytes),
    );

    final response = await client.post(
      path,
      body: request,
      converter: (json) => MultiSigCreateTxResponseDto.fromJson(json),
    );

    return response.data?.txUuid;
  }

  Future<List<MultiSigPendingTx>> getPendingTxs({
    required List<SignerData> signer,
  }) async {
    final result = <MultiSigPendingTx>[];

    final accountsByCoin = signer.groupListsBy((e) => e.coin);
    for (final entry in accountsByCoin.entries) {
      final client = await getClient(entry.key);

      const path = '$_basePath/tx/pending';

      final response = await client.post(
        path,
        body: MultiSigPendingTxRequestDto(
          addresses: entry.value.map((e) => e.address).toList(),
        ),
        listConverter: (json) {
          if (json is String) {
            return <MultiSigTxDto>[];
          }

          return json.map((e) => MultiSigTxDto.fromJson(e)).toList();
        },
      );

      final data = response.data;
      if (data != null) {
        result.addAll(data.map((e) => _fromCreatedTxDto(e)).whereNotNull());
      }
    }

    return result;
  }

  Future<List<MultiSigPendingTx>> getCreatedTxs({
    required List<SignerData> signers,
    MultiSigStatus? status,
  }) async {
    final result = <MultiSigPendingTx>[];

    final accountsByCoin = signers.groupListsBy((e) => e.coin);
    for (final entry in accountsByCoin.entries) {
      final client = await getClient(entry.key);
      const path = '$_basePath/tx/created';

      final response = await client.post(
        path,
        body: MultiSigCreatedTxRequestDto(
          addresses: signers.map((e) => e.address).toList(),
          status: status,
        ),
        listConverter: (json) {
          if (json is String) {
            return <MultiSigTxDto>[];
          }

          return json.map((e) => MultiSigTxDto.fromJson(e)).toList();
        },
      );

      final data = response.data;
      if (data != null) {
        result.addAll(data.map((e) => _fromCreatedTxDto(e)).whereNotNull());
      }
    }

    return result;
  }

  Future<bool> signTx({
    required String signerAddress,
    required Coin coin,
    required String txUuid,
    String? signatureBytes,
    bool? declineTx,
  }) async {
    final client = await getClient(coin);
    const path = '$_basePath/tx/sign';

    final request = MultiSigSignTxRequest(
      address: signerAddress,
      txUuid: txUuid,
      signatureBytes: signatureBytes,
      declineTx: declineTx,
    );

    final response = await client.post(
      path,
      body: request,
    );

    return response.isSuccessful;
  }

  Future<MultiSigUpdateResult> updateTxResult({
    required String txUuid,
    required String txHash,
    required Coin coin,
  }) async {
    const path = '$_basePath/tx/result';
    final client = await getClient(coin);

    final request = MultiSigUpdateTxRequestDto(
      txUuid: txUuid,
      txHash: txHash,
    );

    final response = await client.post(
      path,
      body: request,
    );

    var result = MultiSigUpdateResult.fail;

    if (response.isSuccessful) {
      result = MultiSigUpdateResult.success;
    } else if (response.error?.response?.statusCode == 500) {
      result = MultiSigUpdateResult.error;
    }

    return result;
  }

  MultiSigPendingTx? _fromCreatedTxDto(MultiSigTxDto? dto) {
    MultiSigPendingTx? result;

    try {
      if (dto != null) {
        final txBodyBytes =
            MultiSigTxBodyBytesDto.fromJson(jsonDecode(dto.txBodyBytes));

        result = MultiSigPendingTx(
          multiSigAddress: dto.multiSigAddress,
          signerAddress: dto.signerAddress,
          txUuid: dto.txUuid,
          txBody: txBodyBytes.txBody,
          fee: txBodyBytes.fee,
          status: dto.status,
          signatures: dto.signatures
              .map(
                (e) => MultiSigSignature(
                  signerAddress: e.signerAddress,
                  signatureHex: e.signatureHex,
                  signatureDecline: e.signatureDecline,
                ),
              )
              .toList(),
        );
      }
    } catch (e) {
      logDebug('Invalid $MultiSigTxDto');
    }

    return result;
  }

  MultiSigSigner _toMultiSigSigner({
    required String? publicKeyHex,
    required String inviteUuid,
    required Coin coin,
    required int signerOrder,
  }) {
    PublicKey? publicKey;
    if (publicKeyHex != null) {
      publicKey = publicKeyFromCompressedHex(publicKeyHex, coin);
    }

    return MultiSigSigner(
      publicKey: publicKey,
      inviteId: inviteUuid,
      signerOrder: signerOrder,
    );
  }
}

class SignerData {
  SignerData({
    required this.address,
    required this.coin,
  });

  final String address;
  final Coin coin;
}
