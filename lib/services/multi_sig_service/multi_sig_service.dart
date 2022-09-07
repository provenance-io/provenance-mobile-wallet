import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_create_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_create_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_create_tx_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_create_tx_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_created_tx_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_get_account_by_invite_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_get_accounts_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_pending_tx_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_register_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_register_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_sign_tx_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_tx_body_bytes_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_update_tx_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_pending_tx.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signature.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signer.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_status.dart';
import 'package:provenance_wallet/util/address_util.dart';
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

// TODO-Roy: Rename to MultiSigClient
class MultiSigService with ClientCoinMixin {
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

  Future<MultiSigSigner?> register({
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

    return signer;
  }

  Future<List<MultiSigRemoteAccount>?> getAccounts({
    required String address,
  }) async {
    final coin = getCoinFromAddress(address);
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
  }) async {
    final accounts = await getAccounts(
      address: signerAddress,
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
    required proto.TxBody txBody,
    required proto.Fee fee,
  }) async {
    final coin = getCoinFromAddress(multiSigAddress);
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

  Future<List<MultiSigPendingTx>?> getPendingTxs({
    required String signerAddress,
  }) async {
    final coin = getCoinFromAddress(signerAddress);
    final client = await getClient(coin);
    final path = '$_basePath/tx/pending/$signerAddress';

    final response = await client.get(
      path,
      listConverter: (json) {
        if (json is String) {
          return <MultiSigPendingTxDto>[];
        }

        return json.map((e) => MultiSigPendingTxDto.fromJson(e)).toList();
      },
    );

    List<MultiSigPendingTx>? result;

    final data = response.data;
    if (data != null) {
      result = data.map((e) => _fromPendingTxDto(e)).whereNotNull().toList();
    }

    return result;
  }

  Future<List<MultiSigPendingTx>?> getCreatedTxs({
    required String signerAddress,
  }) async {
    final coin = getCoinFromAddress(signerAddress);
    final client = await getClient(coin);
    final path = '$_basePath/tx/created/$signerAddress';

    final response = await client.get(
      path,
      listConverter: (json) {
        if (json is String) {
          return <MultiSigCreatedTxDto>[];
        }

        return json.map((e) => MultiSigCreatedTxDto.fromJson(e)).toList();
      },
    );

    List<MultiSigPendingTx>? result;

    final data = response.data;
    if (data != null) {
      result = data.map((e) => _fromCreatedTxDto(e)).whereNotNull().toList();
    }

    return result;
  }

  Future<bool> signTx({
    required String signerAddress,
    required String txUuid,
    required String signatureBytes,
  }) async {
    final coin = getCoinFromAddress(signerAddress);
    final client = await getClient(coin);
    const path = '$_basePath/tx/sign';

    final request = MultiSigSignTxRequest(
      address: signerAddress,
      txUuid: txUuid,
      signatureBytes: signatureBytes,
    );

    final response = await client.post(
      path,
      body: request,
    );

    return response.isSuccessful;
  }

  Future<bool> updateTxResult({
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

    return response.isSuccessful;
  }

  MultiSigPendingTx? _fromCreatedTxDto(MultiSigCreatedTxDto? dto) {
    MultiSigPendingTx? result;

    try {
      if (dto != null) {
        final txBodyBytes =
            MultiSigTxBodyBytesDto.fromJson(jsonDecode(dto.txBodyBytes));

        result = MultiSigPendingTx(
          multiSigAddress: dto.multiSigAddress,
          txUuid: dto.txUuid,
          txBody: txBodyBytes.txBody,
          fee: txBodyBytes.fee,
          status: MultiSigStatus.values.byName(dto.status.toLowerCase()),
          signatures: dto.signatures
              ?.map(
                (e) => MultiSigSignature(
                  signerAddress: e.signerAddress,
                  signatureHex: e.signatureHex,
                ),
              )
              .toList(),
        );
      }
    } catch (e) {
      logDebug('Invalid $MultiSigCreatedTxDto');
    }

    return result;
  }

  MultiSigPendingTx? _fromPendingTxDto(MultiSigPendingTxDto? dto) {
    MultiSigPendingTx? result;

    try {
      if (dto != null) {
        final txBodyBytes =
            MultiSigTxBodyBytesDto.fromJson(jsonDecode(dto.txBodyBytes));

        result = MultiSigPendingTx(
          multiSigAddress: dto.multiSigAddress,
          txUuid: dto.txUuid,
          txBody: txBodyBytes.txBody,
          fee: txBodyBytes.fee,
          status: MultiSigStatus.pending,
        );
      }
    } catch (e) {
      logDebug('Invalid $MultiSigPendingTxDto');
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
