import 'package:provenance_wallet/common/pw_design.dart';

///
/// this class allows us to use the navigation bar's back button with in  a
/// nexted flow with out the appBar being aware.
///
class _FlowRootRoute<Y extends FlowBase> extends MaterialPageRoute {
  _FlowRootRoute({
    required WidgetBuilder builder,
    required this.parentNavigator,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );

  final NavigatorState parentNavigator;

  @override
  bool get canPop {
    if (super.canPop) {
      return true;
    }

    return parentNavigator.canPop();
  }

  @override
  Future<RoutePopDisposition> willPop() async {
    var disposition = RoutePopDisposition.bubble;
    final willPop = await super.willPop();

    if (willPop == RoutePopDisposition.bubble) {
      parentNavigator.pop();
      disposition = RoutePopDisposition.doNotPop;
    }

    return disposition;
  }

  @override
  bool didPop(dynamic result) {
    if (super.canPop) {
      return super.didPop(result);
    }

    super.didPop(result); // trigger root flow's dispose method.
    parentNavigator.pop(result);

    return true;
  }
}

abstract class FlowBase extends StatefulWidget {
  const FlowBase({
    Key? key,
  }) : super(key: key);
}

abstract class FlowBaseState<Z extends FlowBase> extends State<Z> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final state = _navigatorKey.currentState!;

        return !await state.maybePop();
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return _FlowRootRoute<Z>(
            parentNavigator: Navigator.of(context),
            settings: settings,
            builder: (context) {
              return createStartPage();
            },
          );
        },
      ),
    );
  }

  Future<X?> showPage<X>(WidgetBuilder builder, {RouteSettings? settings}) {
    final route = MaterialPageRoute<X>(
      settings: settings,
      builder: builder,
    );

    return _navigatorKey.currentState!.push<X>(route);
  }

  Future<X?> replaceLastPage<X>(WidgetBuilder builder,
      {RouteSettings? settings}) {
    final route = MaterialPageRoute<X>(
      settings: settings,
      builder: builder,
    );

    return _navigatorKey.currentState!.pushReplacement(route);
  }

  void completeFlow<X>(X value) {
    final navigator = _navigatorKey.currentState;
    navigator!.popUntil((route) => route is _FlowRootRoute<Z>);

    Navigator.pop(context, value);
  }

  Widget createStartPage();
}
