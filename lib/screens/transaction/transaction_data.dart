import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/common/pw_design.dart';

class TransactionData extends StatefulWidget {
  const TransactionData({
    required this.data,
    Key? key,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  _TransactionDataState createState() => _TransactionDataState();
}

class _TransactionDataState extends State<TransactionData> {
  String? prettyData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    prettyData = prettyJson(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        Spacing.large,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.neutral700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: PwText(
        prettyData ?? '',
        color: PwColor.secondary2,
      ),
    );
  }
}
