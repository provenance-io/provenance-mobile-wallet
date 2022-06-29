import 'package:collection/collection.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_create_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_create_response_dto.dart';
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
        signers: data.signers
            .map(
              (e) => _toMultiSigSigner(
                publicKeyHex: e.publicKey,
                inviteUuid: e.inviteUuid,
                coin: coin,
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
      );
    }

    return signer;
  }

  Future<List<MultiSigRemoteAccount>?> getAccounts({
    required PublicKey publicKey,
  }) async {
    final client = await getClient(publicKey.coin);
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
              signers: e.signers
                  .map(
                    (e) => _toMultiSigSigner(
                      publicKeyHex: e.publicKey,
                      inviteUuid: e.inviteUuid,
                      coin: publicKey.coin,
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
  }) async {
    MultiSigRemoteAccount? account;

    const inviteIds = {
      'e472ec16-4436-46d5-b72d-6a998b80cd82',
      '991198b7-97bb-42dc-8ead-0e783c8ac45b',
      '42ac4c04-f8df-4dd4-80e6-a2933aa0e25c',
    };

    // TODO-Roy: Add service call.
    if (inviteIds.contains(inviteId)) {
      account = MultiSigRemoteAccount(
        remoteId: 'cdfa44a1-7dbd-4be5-8e03-db8a7c6d83c2',
        name: "Roy's Multisig Three",
        signers: [
          MultiSigSigner(
            inviteId: 'e472ec16-4436-46d5-b72d-6a998b80cd82',
          ),
          MultiSigSigner(
            inviteId: '991198b7-97bb-42dc-8ead-0e783c8ac45b',
          ),
          MultiSigSigner(
            inviteId: '42ac4c04-f8df-4dd4-80e6-a2933aa0e25c',
          ),
        ],
        signersRequired: 2,
      );
    }

    return account;
  }

  MultiSigSigner _toMultiSigSigner({
    required String? publicKeyHex,
    required String inviteUuid,
    required Coin coin,
  }) {
    PublicKey? publicKey;
    if (publicKeyHex != null) {
      publicKey = publicKeyFromCompressedHex(publicKeyHex, coin);
    }

    return MultiSigSigner(
      publicKey: publicKey,
      inviteId: inviteUuid,
    );
  }
}
