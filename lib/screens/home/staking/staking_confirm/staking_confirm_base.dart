import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_gas_adjustment_slider.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingConfirmBase extends StatefulWidget {
  const StakingConfirmBase({
    Key? key,
    required this.appBarTitle,
    required this.onDataClick,
    required this.onTransactionSign,
    required this.signButtonTitle,
    this.children = const <Widget>[],
  }) : super(key: key);

  final String appBarTitle;
  final VoidCallback onDataClick;
  final Function(double?) onTransactionSign;
  final String signButtonTitle;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => _StakingConfirmBaseState();
}

class _StakingConfirmBaseState extends State<StakingConfirmBase> {
  double _gasEstimate = defaultGasEstimate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.neutral750,
        elevation: 0.0,
        centerTitle: true,
        title: PwText(
          widget.appBarTitle,
          style: PwTextStyle.footnote,
          textAlign: TextAlign.left,
        ),
        leading: Flexible(
          child: IconButton(
            icon: PwIcon(
              PwIcons.back,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          PwTextButton(
            minimumSize: Size(
              80,
              50,
            ),
            onPressed: () {
              widget.onDataClick();
            },
            child: PwText(
              Strings.of(context).stakingConfirmData,
              style: PwTextStyle.footnote,
              underline: true,
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: Spacing.large),
          children: [
            Column(
              children: [
                ...widget.children,
                PwListDivider.alternate(),
                PwGasAdjustmentSlider(
                  title: Strings.of(context).stakingConfirmGasAdjustment,
                  startingValue: defaultGasEstimate,
                  onValueChanged: (value) {
                    setState(() {
                      _gasEstimate = value;
                    });
                  },
                ),
                PwListDivider.alternate(),
                VerticalSpacer.largeX3(),
                Expanded(child: Container()),
                PwButton(
                  onPressed: () {
                    widget.onTransactionSign(_gasEstimate);
                  },
                  child: PwText(
                    widget.signButtonTitle,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
                VerticalSpacer.largeX3(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
