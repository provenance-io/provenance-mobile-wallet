import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';

class FwShowModalBottomSheet {
  final Widget? normalChild;
  final Widget? fractionalChild;
  final topRadius;
  final BuildContext context;
  final bool isDismissible;
  final bool isScrollControlled;

  FwShowModalBottomSheet(this.context,
      {this.normalChild,
      this.fractionalChild,
      this.topRadius,
      this.isDismissible = false,
      this.isScrollControlled = false});

  Future<T?> show<T>() {
    final radius = topRadius ?? Radius.circular(4.0);

    return showModalBottomSheet<T>(
        isDismissible: isDismissible,
        isScrollControlled: isScrollControlled,
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
        ),
        barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.8),
        clipBehavior: Clip.antiAlias,
        context: context,
        builder: (BuildContext bc) {
          if (normalChild != null) {
            return Container(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[normalChild!],
              ),
            );
          }

          if (fractionalChild != null) {
            return Container(color: Colors.transparent, child: fractionalChild);
          }

          return SizedBox();
        });
  }
}
