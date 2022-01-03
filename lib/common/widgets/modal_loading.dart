import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';

class ModalLoading extends StatefulWidget {
  final String? loadingMessage;
  final Key? key;

  ModalLoading({this.key, this.loadingMessage}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ModalLoadingState(loadingMessage: this.loadingMessage);
  }
}

class ModalLoadingState extends State<ModalLoading> {
  String? loadingMessage;

  ModalLoadingState({this.loadingMessage});

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: true,
      child: loadingMessage != null ? FwText(
        loadingMessage!
      ) : Container(),
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
  Duration get transitionDuration => _kDropdownMenuDuration;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.transparent;

  @override
  final String? barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return ModalLoading(
        key: loadingState,
        loadingMessage: loadingMessage,
      );
    });
  }

  static dismiss(BuildContext context) {
    try {
      if (instance != null) {
        Navigator.of(context).removeRoute(instance!);
      }
    } catch (e) {}
    ;
    instance = null;
  }

  static ModalLoadingRoute? instance;

  static showLoading(String message, BuildContext context) {
    if (instance != null) {
      instance?.loadingState.currentState?.updateMessage(message);
    } else {
      instance = ModalLoadingRoute(loadingMessage: message);
      Navigator.push(context, instance!);
    }
  }
}
