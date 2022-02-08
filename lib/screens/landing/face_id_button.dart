import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/util/strings.dart';

class FaceIdButton extends StatelessWidget {
  FaceIdButton({
    required this.authType,
    required this.accountExists,
    required this.doAuth,
  });
  final String authType;
  final bool accountExists;
  final Function doAuth;

  @override
  Widget build(BuildContext context) {
    if (!accountExists) {
      return Container();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Visibility(
            visible: accountExists,
            child: PwOutlinedButton(
              Strings.signInWithBiometric(authType),
              icon: PwIcon(
                PwIcons.faceScan,
                color: Theme.of(context).colorScheme.white,
              ),
              fpTextStyle: PwTextStyle.mBold,
              fpTextColor: PwColor.white,
              backgroundColor: Theme.of(context).colorScheme.globalNeutral450,
              borderColor: Theme.of(context).colorScheme.globalNeutral450,
              onPressed: () => doAuth(),
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
