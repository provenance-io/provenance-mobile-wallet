import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/common/widgets/pw_slider.dart';
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
          style: PwTextStyle.subhead,
          textAlign: TextAlign.left,
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 21),
          child: Flexible(
            child: IconButton(
              icon: PwIcon(
                PwIcons.back,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 21),
            child: PwTextButton(
              minimumSize: Size(
                80,
                50,
              ),
              onPressed: () {
                widget.onDataClick();
              },
              child: PwText(
                Strings.stakingConfirmData,
                style: PwTextStyle.body,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: ListView(
          children: [
            ...widget.children,
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            PwSlider(
              title: Strings.stakingConfirmGasAdjustment,
              startingValue: defaultGasEstimate,
              min: 0,
              max: 5,
              onValueChanged: (value) {
                setState(() {
                  _gasEstimate = value;
                });
              },
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.largeX3,
                  vertical: Spacing.xLarge,
                ),
                child: Flexible(
                  child: PwButton(
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
                )),
          ],
        ),
      ),
    );
  }
}
