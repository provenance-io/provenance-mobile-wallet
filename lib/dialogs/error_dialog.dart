import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    Key? key,
    this.error,
  }) : super(key: key);

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
              child: FwButton(
                child: FwText(
                  'OK',
                  style: FwTextStyle.mBold,
                  color: FwColor.white,
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
