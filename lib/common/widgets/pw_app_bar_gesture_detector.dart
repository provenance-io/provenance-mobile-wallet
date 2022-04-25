import 'package:provenance_blockchain_wallet/common/pw_design.dart';

class PwAppBarGestureDetector extends StatelessWidget
    implements PreferredSizeWidget {
  const PwAppBarGestureDetector({
    required PreferredSizeWidget child,
    Function()? onTap,
    Key? key,
  })  : _child = child,
        _onTap = onTap,
        super(key: key);

  final PreferredSizeWidget _child;
  final Function()? _onTap;

  @override
  Size get preferredSize => _child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: _child,
    );
  }
}
