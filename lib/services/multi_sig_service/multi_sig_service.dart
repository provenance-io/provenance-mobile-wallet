import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_finalize_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_get_accounts_response_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_register_request_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_signer_dto.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_registration.dart';
import 'package:uuid/uuid.dart';

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

  final _samples = <String, MultiSigGetAccountsResponseDto>{};

  Future<MultiSigRegistration?> register({
    required String name,
    required int cosignerCount,
    required int threshold,
    required PublicKey linkedPublicKey,
  }) async {
    final numOfAdditionalSigners = cosignerCount - 1;
    final coin = linkedPublicKey.coin;
    final chainId = ChainId.forCoin(coin);

    final body = MultiSigRegisterRequestDto(
      name: name,
      publicKey: linkedPublicKey.compressedPublicKeyHex,
      address: linkedPublicKey.address,
      numOfAdditionalSigners: numOfAdditionalSigners,
      threshold: threshold,
      chainId: chainId,
    );

    final inviteId = Uuid().v1().toString();
    final signers = <MultiSigSignerDto>[];
    for (var i = 0; i < cosignerCount; i++) {
      final signerId = Uuid().v1().toString();
      final signer = MultiSigSignerDto(
        signerUuid: signerId,
        inviteUuid: inviteId,
        originalSigner: i == 0,
      );
      signers.add(signer);
    }
    final sample = MultiSigGetAccountsResponseDto(
      name: name,
      walletUuid: inviteId,
      threshold: threshold,
      status: 'PENDING',
      chainId: chainId,
      signers: signers,
    );
    _samples[inviteId] = sample;

    // final client = await getClient(coin);
    // const path = '$_basePath/register';
    // final response = await client.post(
    //   path,
    //   body: body,
    //   converter: (json) => MultiSigCreateResponseDto.fromJson(json),
    // );

    MultiSigRegistration? invite;

    // final data = response.data;
    // if (data != null) {
    //   invite = MultiSigRegistration(
    //     id: data.walletUuid,
    //     name: data.name,
    //     inviteLinks: data.inviteLinks,
    //   );
    // }

    final inviteLinks = <String>[];
    for (var i = 0; i < cosignerCount - 1; i++) {
      inviteLinks.add('https://provenance.io/invite/$i');
    }
    invite = MultiSigRegistration(
      id: inviteId,
      name: name,
      inviteLinks: inviteLinks,
    );

    return invite;
  }

  Future<List<MultiSigGetAccountsResponseDto>?> getAccounts({
    required String address,
    required Coin coin,
  }) async {
    // final client = await getClient(coin);
    // final path = '$_basePath/by-address/$address';
    // final response = await client.get(
    //   path,
    //   listConverter: (json) {
    //     if (json is String) {
    //       return <MultiSigGetAccountsResponseDto>[];
    //     }

    //     return json
    //         .map((e) => MultiSigGetAccountsResponseDto.fromJson(e))
    //         .toList();
    //   },
    // );

    // return response.data;
    return _samples.values.toList();
  }

  Future<bool> finalize({
    required String accountId,
    required PublicKey publicKey,
  }) async {
    final client = await getClient(publicKey.coin);
    const path = '$_basePath/finalize';
    final response = await client.post(
      path,
      body: MultiSigFinalizeRequestDto(
        walletUuid: accountId,
        publicKey: publicKey.compressedPublicKeyHex,
      ),
    );

    return response.isSuccessful;
  }
}
