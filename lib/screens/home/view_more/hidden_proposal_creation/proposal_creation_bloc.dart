import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_cosmos_gov_v1beta1.dart' as gov;
import 'package:provenance_wallet/common/classes/transaction_bloc.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/denom_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class ProposalCreationBloc extends TransactionBloc {
  ProposalCreationBloc(
    TransactableAccount account,
  ) : super(account);

  final _creationDetails = BehaviorSubject.seeded(ProposalCreationDetails(
    hashAmount: Decimal.zero,
    initialDeposit: Decimal.zero,
  ));

  ValueStream<ProposalCreationDetails?> get creationDetails => _creationDetails;

  Future<void> load({bool showLoading = true}) async {
    final oldDetails = _creationDetails.value;

    if (showLoading) {
      _creationDetails.tryAdd(
        ProposalCreationDetails.fromExisting(
          oldDetails,
          isLoading: true,
        ),
      );
    }

    try {
      final assets =
          await get<AssetClient>().getAssets(account.coin, account.address);

      Decimal hash = Decimal.zero;

      if (assets.isNotEmpty) {
        final asset = assets.firstWhere((element) => element.denom == 'nhash');
        hash = nHashToHash(BigInt.parse(asset.amount));
      }

      _creationDetails.tryAdd(
        ProposalCreationDetails.fromExisting(
          oldDetails,
          hashAmount: hash,
        ),
      );
    } finally {
      if (showLoading) {
        final newerDetatils = _creationDetails.value;
        _creationDetails.tryAdd(
          ProposalCreationDetails.fromExisting(
            newerDetatils,
            isLoading: false,
          ),
        );
      }
    }
  }

  @override
  gov.MsgSubmitProposal getMessage() {
    final details = _creationDetails.value;
    final scaledAmount = hashToNHash(
      details.initialDeposit,
      ignoreScaleError: true,
    ).toString();

    return gov.MsgSubmitProposal(
      content: gov.TextProposal(
        title: details.title,
        description: details.description,
      ).toAny(),
      initialDeposit: details.initialDeposit > Decimal.zero
          ? [
              Coin(
                denom: nHashDenom,
                amount: scaledAmount,
              )
            ]
          : null,
      proposer: account.address,
    );
  }

  void updateTitle(String text) {
    final oldDetatils = _creationDetails.value;
    _creationDetails.tryAdd(
      ProposalCreationDetails.fromExisting(
        oldDetatils,
        title: text,
      ),
    );
  }

  void updateDescription(String text) {
    final oldDetatils = _creationDetails.value;
    _creationDetails.tryAdd(
      ProposalCreationDetails.fromExisting(
        oldDetatils,
        description: text,
      ),
    );
  }

  void updateInitialDeposit(double deposit) {
    final oldDetatils = _creationDetails.value;
    _creationDetails.tryAdd(
      ProposalCreationDetails.fromExisting(
        oldDetatils,
        initialDeposit: Decimal.tryParse(deposit.toString()),
      ),
    );
  }

  @override
  FutureOr onDispose() {
    _creationDetails.close();
  }
}

class ProposalCreationDetails {
  ProposalCreationDetails({
    this.isLoading = true,
    required this.initialDeposit,
    required this.hashAmount,
    this.title = "",
    this.description = "",
  });

  static ProposalCreationDetails fromExisting(
    ProposalCreationDetails existing, {
    bool? isLoading,
    Decimal? initialDeposit,
    Decimal? hashAmount,
    String? title,
    String? description,
  }) {
    return ProposalCreationDetails(
      initialDeposit: initialDeposit ?? existing.initialDeposit,
      description: description ?? existing.description,
      hashAmount: hashAmount ?? existing.hashAmount,
      isLoading: isLoading ?? existing.isLoading,
      title: title ?? existing.title,
    );
  }

  final bool isLoading;
  final Decimal initialDeposit;
  final Decimal hashAmount;
  final String title;
  final String description;
}
