import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_edit_count.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class MultiSigCountScreen extends StatefulWidget {
  const MultiSigCountScreen._({
    required this.title,
    required this.message,
    required this.description,
    required this.mode,
    required this.onConfirm,
    required this.stream,
    this.currentStep,
    this.totalSteps,
    Key? key,
  }) : super(key: key);

  factory MultiSigCountScreen.signatures({
    required AddAccountFlowBloc bloc,
    required FieldMode mode,
    required String title,
    required String message,
    required String description,
    int? currentStep,
    int? totalSteps,
    Key? key,
  }) {
    void Function(int count) onConfirm;

    switch (mode) {
      case FieldMode.initial:
        onConfirm = bloc.submitMultiSigSignatures;
        break;
      case FieldMode.edit:
        onConfirm = bloc.setSignatureCount;
        break;
    }

    return MultiSigCountScreen._(
      title: title,
      message: message,
      description: description,
      mode: mode,
      currentStep: currentStep,
      totalSteps: totalSteps,
      stream: bloc.multiSigSignatureCount,
      onConfirm: onConfirm,
    );
  }

  factory MultiSigCountScreen.cosigners({
    required AddAccountFlowBloc bloc,
    required FieldMode mode,
    required String title,
    required String message,
    required String description,
    int? currentStep,
    int? totalSteps,
    Key? key,
  }) {
    void Function(int count) onConfirm;

    switch (mode) {
      case FieldMode.initial:
        onConfirm = bloc.submitMultiSigCosigners;
        break;
      case FieldMode.edit:
        onConfirm = bloc.setCosignerCount;
        break;
    }

    return MultiSigCountScreen._(
      title: title,
      message: message,
      description: description,
      mode: mode,
      currentStep: currentStep,
      totalSteps: totalSteps,
      stream: bloc.multiSigCosignerCount,
      onConfirm: onConfirm,
    );
  }

  final FieldMode mode;
  final int? currentStep;
  final int? totalSteps;
  final String title;
  final String message;
  final String description;
  final ValueStream<Count> stream;
  final void Function(int count) onConfirm;

  @override
  State<MultiSigCountScreen> createState() => _MultiSigCountScreenState();
}

class _MultiSigCountScreenState extends State<MultiSigCountScreen> {
  final subscriptions = CompositeSubscription();
  var value = 0;
  int? min;
  int? max;

  @override
  void dispose() {
    subscriptions.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    widget.stream.listen((e) {
      if (value != e.value) {
        setState(() {
          value = e.value;
          min = e.min;
          max = e.max;
        });
      }
    }).addTo(subscriptions);
  }

  @override
  Widget build(BuildContext context) {
    String? leadingIcon;
    String confirmButtonLabel;
    bool pop;

    switch (widget.mode) {
      case FieldMode.initial:
        leadingIcon = PwIcons.back;
        confirmButtonLabel = Strings.of(context).multiSigNextButton;
        pop = false;
        break;
      case FieldMode.edit:
        leadingIcon = PwIcons.close;
        confirmButtonLabel = Strings.of(context).multiSigSaveButton;
        pop = true;
        break;
    }

    return Scaffold(
      appBar: PwAppBar(
        title: widget.title,
        leadingIcon: leadingIcon,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
                VerticalSpacer.large(),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: PwText(
                    widget.message,
                    style: PwTextStyle.bodyBold,
                    textAlign: TextAlign.center,
                    color: PwColor.neutralNeutral,
                  ),
                ),
                VerticalSpacer.large(),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: PwText(
                    widget.description,
                    style: PwTextStyle.footnote,
                    textAlign: TextAlign.center,
                    color: PwColor.neutralNeutral,
                  ),
                ),
                VerticalSpacer.largeX3(),
                PwEditCount(
                  count: value,
                  min: min,
                  max: max,
                  onChanged: (count) {
                    setState(() {
                      value = count;
                    });
                  },
                ),
                Expanded(
                  child: SizedBox(),
                  flex: 2,
                ),
                VerticalSpacer.large(),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: PwButton(
                      child: PwText(
                        confirmButtonLabel,
                        style: PwTextStyle.bodyBold,
                        color: PwColor.neutralNeutral,
                      ),
                      onPressed: () {
                        widget.onConfirm(value);

                        if (pop) {
                          Navigator.of(context).pop();
                        }
                      }),
                ),
                VerticalSpacer.largeX4(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
