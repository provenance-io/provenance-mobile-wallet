import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingTransactionDataScreen extends StatelessWidget {
  const StakingTransactionDataScreen({
    Key? key,
    required this.data,
  }) : super(key: key);
  final Object? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.stakingConfirmData,
        leadingIcon: PwIcons.back,
        style: PwTextStyle.footnote,
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: Spacing.large,
              right: Spacing.large,
              top: Spacing.largeX3,
            ),
            child: Container(
              color: Theme.of(context).colorScheme.neutral700,
              child: Padding(
                padding: EdgeInsets.all(
                  Spacing.large,
                ),
                child: PwText(
                  prettyJson(data),
                  color: PwColor.secondary350,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
