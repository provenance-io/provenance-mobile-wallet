import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    Key? key,
    this.error,
  }) : super(key: key);

  factory ErrorDialog.fromException(dynamic exception, { Key? key }) {
    final msg = exception.toString().replaceFirst(RegExp('^[^:]+: '), "");

    return ErrorDialog(
      key: key,
      error: msg,
    );
  }

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 40),
            Text(
              error ?? 'Invalid',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(color: Theme.of(context).colorScheme.black),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: PwButton(
                child: PwText(
                  'OK',
                  style: PwTextStyle.mBold,
                  color: PwColor.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
