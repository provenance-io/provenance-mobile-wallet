import 'package:provenance_wallet/common/pw_design.dart';

class PwAppBar extends StatefulWidget implements PreferredSizeWidget {
  const PwAppBar({
    Key? key,
    this.title,
    this.leadingIcon,
    this.hasIcon,
    this.color,
    this.leadingIconOnPress,
    this.bottom,
  }) : super(key: key);

  final String? title;
  final String? leadingIcon;
  final bool? hasIcon;
  final Function? leadingIconOnPress;
  final Color? color;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  _PwAppBarState createState() => _PwAppBarState();
}

class _PwAppBarState extends State<PwAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.color ?? Theme.of(context).colorScheme.neutral750,
      elevation: 0.0,
      centerTitle: true,
      title: PwText(
        widget.title ?? "",
        style: PwTextStyle.subhead,
        textAlign: TextAlign.left,
      ),
      bottom: widget.bottom,
      leading: (widget.hasIcon ?? true)
          ? Padding(
              padding: EdgeInsets.only(left: 21),
              child: IconButton(
                icon: PwIcon(
                  widget.leadingIcon ?? PwIcons.close,
                ),
                onPressed: () {
                  if (widget.leadingIconOnPress != null) {
                    widget.leadingIconOnPress!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            )
          : Container(),
    );
  }
}
