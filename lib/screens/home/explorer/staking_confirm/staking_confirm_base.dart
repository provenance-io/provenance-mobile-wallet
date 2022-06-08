import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
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
  final Function(double) onTransactionSign;
  final String signButtonTitle;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => _StakingConfirmBaseState();
}

class _StakingConfirmBaseState extends State<StakingConfirmBase> {
  late final TextEditingController _textEditingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

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
        child: ListView(children: [
          ...widget.children,
          PwListDivider(
            indent: Spacing.largeX3,
          ),
          DetailsItem(
            title: Strings.stakingConfirmGasAdjustment,
            endChild: Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Form(
                      key: _formKey,
                      child: StakingTextFormField(
                        hint: Strings.stakingConfirmHash,
                        textEditingController: _textEditingController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PwListDivider(
            indent: Spacing.largeX3,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.largeX3,
              vertical: Spacing.xLarge,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: PwButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: PwText(
                      Strings.stakingConfirmBack,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      color: PwColor.neutralNeutral,
                      style: PwTextStyle.body,
                    ),
                  ),
                ),
                HorizontalSpacer.large(),
                Flexible(
                  child: PwButton(
                    onPressed: () {
                      final updatedGas =
                          double.tryParse(_textEditingController.text) ?? 1.25;
                      widget.onTransactionSign(updatedGas);
                    },
                    child: PwText(
                      widget.signButtonTitle,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      color: PwColor.neutralNeutral,
                      style: PwTextStyle.body,
                    ),
                  ),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
