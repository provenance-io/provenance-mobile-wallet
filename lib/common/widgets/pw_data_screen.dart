import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';

class PwDataScreen extends StatelessWidget {
  const PwDataScreen({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  final String title;
  final Object? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: title,
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
