import 'package:provenance_blockchain_wallet/common/pw_design.dart';

///
/// this class allows us to use the navigation bar's back button with in  a
/// nexted flow with out the appBar being aware.
///
class _FlowRootRoute<Y extends FlowBase> extends MaterialPageRoute {
  _FlowRootRoute({
    required WidgetBuilder builder,
    required this.parentContext,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );

  final BuildContext parentContext;

  @override
  bool get canPop {
    if (super.canPop) {
      return true;
    }

    final parentNavigator = Navigator.of(parentContext);

    return parentNavigator.canPop();
  }

  @override
  Future<RoutePopDisposition> willPop() {
    if (super.canPop) {
      return super.willPop();
    }

    return Future.value(RoutePopDisposition.pop);
  }

  @override
  bool didPop(dynamic result) {
    if (super.canPop) {
      return super.didPop(result);
    }

    super.didPop(result); // trigger root flow's dispose method.
    Navigator.pop(parentContext, result);

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
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        return _FlowRootRoute<Z>(
          parentContext: context,
          settings: settings,
          builder: (context) {
            return createStartPage();
          },
        );
      },
    );
  }

  Future<X?> showPage<X>(WidgetBuilder builder, {RouteSettings? settings}) {
    final route = MaterialPageRoute<X>(
      settings: settings,
      builder: builder,
    );

    return _navigatorKey.currentState!.push<X>(route);
  }

  void completeFlow<X>(X value) {
    final navigator = _navigatorKey.currentState;
    navigator!.popUntil((route) => route is _FlowRootRoute<Z>);

    Navigator.pop(context, value);
  }

  Widget createStartPage();
}
