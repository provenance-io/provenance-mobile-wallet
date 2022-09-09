import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/common/classes/transaction_bloc.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/denom_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class ProposalCreationBloc extends TransactionBloc {
  ProposalCreationBloc(
    TransactableAccount account,
  ) : super(account);

  final _creationDetails = BehaviorSubject.seeded(ProposalCreationDetails());

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
      final asset =
          (await get<AssetService>().getAssets(account.coin, account.address))
              .firstWhere((element) => element.denom == nHashDenom);

      _creationDetails.tryAdd(
        ProposalCreationDetails.fromExisting(
          oldDetails,
          hashAmount: nHashToHash(BigInt.parse(asset.amount)).toDouble(),
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
    final scaledAmount =
        hashToNHash(Decimal.parse(details.initialDeposit.toInt().toString()))
            .toString();

    return gov.MsgSubmitProposal(
      content: gov.TextProposal(
        title: details.title,
        description: details.description,
      ).toAny(),
      initialDeposit: details.initialDeposit.toInt() > 0
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
        initialDeposit: deposit,
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
    this.initialDeposit = 0,
    this.hashAmount = 0,
    this.title = "",
    this.description = "",
  });

  static ProposalCreationDetails fromExisting(
    ProposalCreationDetails existing, {
    bool? isLoading,
    double? initialDeposit,
    double? hashAmount,
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
  final double initialDeposit;
  final double hashAmount;
  final String title;
  final String description;
}
