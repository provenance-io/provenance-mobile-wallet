import 'package:provenance_wallet/common/pw_design.dart';

class ModalLoading extends StatefulWidget {
  const ModalLoading({
    Key? key,
    this.loadingMessage,
  }) : super(key: key);

  final String? loadingMessage;

  @override
  State<StatefulWidget> createState() => ModalLoadingState();
}

class ModalLoadingState extends State<ModalLoading> {
  String? loadingMessage;

  @override
  void initState() {
    loadingMessage = widget.loadingMessage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: true,
      child: loadingMessage != null
          ? Material(
              child: PwText(
                loadingMessage!,
                color: PwColor.neutralNeutral,
                style: PwTextStyle.body,
              ),
            )
          : Container(),
    );
  }

  void updateMessage(String newMessage) async {
    setState(() {
      loadingMessage = newMessage;
    });
  }

//  void dismissLoading() async {
//    Navigator.of(context)?.pop();
//  }
}

const Duration _kDropdownMenuDuration = Duration(milliseconds: 300);

class ModalLoadingRoute extends PopupRoute {
  ModalLoadingRoute({
//    this.items,
    this.padding,
    this.buttonRect,
    this.selectedIndex,
    this.elevation = 8,
    this.loadingMessage,
    this.theme,
    this.height,
//    @required this.style,
    this.barrierLabel,
  });

  final double? height;
//  final List<DropdownMenuItem<T>> items;
  final EdgeInsetsGeometry? padding;
  final Rect? buttonRect;
  final int? selectedIndex;
  final int? elevation;
  final ThemeData? theme;
//  final TextStyle style;
  String? loadingMessage;

  ScrollController? scrollController;

  GlobalKey<ModalLoadingState> loadingState = GlobalKey();

  @override
  final String? barrierLabel;

  static ModalLoadingRoute? instance;

  @override
  Duration get transitionDuration => _kDropdownMenuDuration;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.transparent;

  static dismiss(BuildContext context) {
    try {
      if (instance != null) {
        Navigator.of(context).removeRoute(instance!);
      }
    } catch (e) {
      // Nothing to do here.
    }

    instance = null;
  }

  static showLoading(
    String message,
    BuildContext context,
  ) {
    if (instance != null) {
      instance?.loadingState.currentState?.updateMessage(message);
    } else {
      instance =
          ModalLoadingRoute(loadingMessage: message, theme: Theme.of(context));
      Navigator.push(
        context,
        instance!,
      );
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        return ModalLoading(
          key: loadingState,
          loadingMessage: loadingMessage,
        );
      },
    );
  }
}
