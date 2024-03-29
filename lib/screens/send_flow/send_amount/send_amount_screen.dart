import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class DecimalPointFormatter extends TextInputFormatter {
  DecimalPointFormatter(this.decimalCount) : assert(decimalCount >= 0);

  final int decimalCount;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final decimalIndex = text.indexOf(".");
    if (decimalIndex >= 0) {
      final decimals = text.length - (decimalIndex + 1);
      if (decimals > decimalCount) {
        return oldValue;
      }
    }

    return newValue;
  }
}

class SendAmountScreen extends StatelessWidget {
  const SendAmountScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).sendAmountTitle,
        leadingIcon: PwIcons.back,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.medium,
          horizontal: Spacing.large,
        ),
        child: SendAmountPage(),
      ),
    );
  }
}

class SendAmountPage extends StatefulWidget {
  const SendAmountPage({
    Key? key,
  }) : super(key: key);

  static final keyEnterAmountField =
      ValueKey('$SendAmountPage.enter_amount_field');
  static final keyNextButton = ValueKey('$SendAmountPage.next_button');

  @override
  State<StatefulWidget> createState() => SendAmountPageState();
}

class SendAmountPageState extends State<SendAmountPage> {
  SendAmountBloc? _bloc;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _feeNotifier = ValueNotifier<String?>(null);
  final FocusNode _noteFocusNode = FocusNode();
  final _focusNotifier = ValueNotifier(false);
  final ValueNotifier<String> _fiatValueNotifier = ValueNotifier("");

  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();

    _focusNotifier.value = _noteFocusNode.hasFocus;
    _noteFocusNode.addListener(() {
      _focusNotifier.value = _noteFocusNode.hasFocus;
    });

    _bloc = get<SendAmountBloc>();
    _feeNotifier.addListener(_updateSendPrice);

    _streamSubscription = _bloc!.stream.listen((blocState) {
      if (blocState.transactionFees == null) {
        _feeNotifier.value = null;
      }

      _feeNotifier.value = blocState.transactionFees?.displayAmount;
    });
    _amountController.addListener(_updateSendPrice);
  }

  @override
  void dispose() {
    _noteFocusNode.dispose();
    _streamSubscription?.cancel();

    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = _bloc!.asset;
    const imageDimen = 128.0;
    final padding = EdgeInsets.all(
      Spacing.large,
    );
    final blankInputBorder = OutlineInputBorder(
      borderSide: BorderSide.none,
    );

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Assets.getSvgPictureFrom(
                denom: asset.denom,
                size: imageDimen,
              ),
              VerticalSpacer.medium(),
              TextFormField(
                key: SendAmountPage.keyEnterAmountField,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textAlign: TextAlign.center,
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (newValue) => _bloc?.validateAmount(newValue),
                autofocus: true,
                style: Theme.of(context).textTheme.display1,
                inputFormatters: [
                  DecimalPointFormatter(asset.exponent),
                ],
                decoration: InputDecoration(
                  hintText: Strings.of(context).sendAmountHint,
                  hintStyle: Theme.of(context).textTheme.displayBody.copyWith(
                        color: Theme.of(context).colorScheme.neutralNeutral,
                      ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              VerticalSpacer.medium(),
              PwText(
                "${asset.displayAmount} ${asset.displayDenom} ${Strings.of(context).sendAmountAvailable}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PwTextStyle.displayBody,
              ),
              ValueListenableBuilder<String>(
                valueListenable: _fiatValueNotifier,
                builder: (
                  context,
                  value,
                  child,
                ) {
                  return PwAutoSizingText(
                    value,
                    height: 25,
                    style: PwTextStyle.displayBody,
                    key: ValueKey("DollarValueSent"),
                  );
                },
              ),
              VerticalSpacer.medium(),
              Container(
                key: ValueKey("NoteRow"),
                decoration: null,
                padding: padding,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        style: Theme.of(context).textTheme.body.copyWith(
                              color:
                                  Theme.of(context).colorScheme.neutralNeutral,
                            ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(right: Spacing.large),
                          border: blankInputBorder,
                          enabledBorder: blankInputBorder,
                          focusedBorder: blankInputBorder,
                          hintText: Strings.of(context).sendAmountNoteHint,
                          hintStyle: Theme.of(context).textTheme.body.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .neutralNeutral,
                              ),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _focusNotifier,
                      builder: (
                        context,
                        hasFocus,
                        child,
                      ) {
                        return (!hasFocus && _noteController.text.isEmpty)
                            ? GestureDetector(
                                child: PwText(
                                  Strings.of(context).sendAmountNoteSuffix,
                                  style: PwTextStyle.body,
                                ),
                                onTap: () {
                                  _noteFocusNode.requestFocus();
                                },
                              )
                            : SizedBox(
                                width: 0,
                                height: 0,
                              );
                      },
                    ),
                  ],
                ),
              ),
              PwDivider(
                height: 1,
                indent: Spacing.large,
                endIndent: Spacing.large,
              ),
              Container(
                key: ValueKey("FeeRow"),
                decoration: null,
                padding: padding,
                child: ValueListenableBuilder<String?>(
                  valueListenable: _feeNotifier,
                  builder: (
                    context,
                    fee,
                    child,
                  ) {
                    final msg =
                        fee ?? Strings.of(context).sendAmountLoadingFeeEstimate;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PwText(Strings.of(context).sendAmountTransactionLabel),
                        Expanded(
                          child: PwText(
                            msg,
                            textAlign: TextAlign.end,
                            style: PwTextStyle.body,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(child: Container()),
              VerticalSpacer.xxLarge(),
              ValueListenableBuilder(
                valueListenable: _feeNotifier,
                builder: (
                  context,
                  value,
                  child,
                ) =>
                    PwButton(
                  key: SendAmountPage.keyNextButton,
                  child: PwText(
                    Strings.of(context).sendAmountNextButton,
                    style: PwTextStyle.bodyBold,
                  ),
                  enabled: value != null,
                  onPressed: () => _next(context),
                ),
              ),
              VerticalSpacer.large(),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _next(BuildContext context) async {
    try {
      await _bloc!.showNext(_noteController.text, _amountController.text);
    } catch (error) {
      PwDialog.showError(
        context: context,
        error: error,
      );
    }
  }

  void _updateSendPrice() {
    final text = _amountController.text;
    final sendAmount = Decimal.tryParse(text);

    if (sendAmount == null) {
      _fiatValueNotifier.value = "";
    } else {
      final scaledAmount =
          (sendAmount * Decimal.fromInt(10).pow(_bloc!.asset.exponent));
      final convertedAsset = _bloc!.asset.copyWith(amount: scaledAmount);

      _fiatValueNotifier.value = convertedAsset.displayFiatAmount;
    }
  }
}
