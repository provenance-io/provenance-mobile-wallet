import 'package:collection/collection.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_create_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_create_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_get_account_by_invite_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_get_accounts_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_register_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_register_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signer.dart';
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
    required PublicKey publicKey,
  }) async {
    final coin = publicKey.coin;
    final client = await getClient(coin);
    final path = '$_basePath/by-address/${publicKey.address}';

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
            ),
          )
          .toList();
    }

    return accounts;
  }

  Future<MultiSigRemoteAccount?> getAccount({
    required String remoteId,
    required PublicKey signerPublicKey,
  }) async {
    final accounts = await getAccounts(
      publicKey: signerPublicKey,
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
      );
    }

    return account;
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
