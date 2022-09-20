import 'package:provenance_wallet/common/pw_design.dart';

typedef AwaitedFunction = Future<void> Function();

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
}

const Duration _kDropdownMenuDuration = Duration(milliseconds: 300);

class ModalLoadingRoute extends PopupRoute {
  ModalLoadingRoute({
    this.padding,
    this.buttonRect,
    this.selectedIndex,
    this.elevation = 8,
    this.theme,
    this.height,
    this.barrierLabel,
  });

  final double? height;
  final EdgeInsetsGeometry? padding;
  final Rect? buttonRect;
  final int? selectedIndex;
  final int? elevation;
  final ThemeData? theme;

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
        Navigator.of(context, rootNavigator: true).removeRoute(instance!);
      }
    } catch (e) {
      // Nothing to do here.
    }

    instance = null;
  }

  // TODO: Refactor this so you have to pass in an awaited function.

  static showLoading(
    BuildContext context, {
    Duration? minDisplayTime,
    AwaitedFunction? toComplete,
  }) async {
    if (instance != null) {
      instance?.loadingState.currentState?.updateMessage("");
    } else {
      instance = ModalLoadingRoute(theme: Theme.of(context));
      Navigator.of(context, rootNavigator: true).push(instance!);
      await Future.delayed(minDisplayTime ?? Duration(milliseconds: 0));
      if (toComplete != null) {
        await toComplete();
        await dismiss(context);
      }
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
        );
      },
    );
  }
}
