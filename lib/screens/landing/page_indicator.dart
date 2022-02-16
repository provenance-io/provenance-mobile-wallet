import 'package:provenance_wallet/common/pw_design.dart';

class PageIndicator extends StatelessWidget {
  PageIndicator({
    required this.currentPageIndex,
  });

  final int currentPageIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 4,
          width: 30,
          decoration: BoxDecoration(
            border: Border.all(
              color: _getColor(0, context),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _getColor(0, context),
          ),
        ),
        HorizontalSpacer.small(),
        Container(
          height: 4,
          width: 30,
          decoration: BoxDecoration(
            border: Border.all(
              color: _getColor(1, context),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _getColor(1, context),
          ),
        ),
        HorizontalSpacer.small(),
        Container(
          height: 4,
          width: 30,
          decoration: BoxDecoration(
            border: Border.all(
              color: _getColor(2, context),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _getColor(2, context),
          ),
        ),
      ],
    );
  }

  Color _getColor(int index, BuildContext context) {
    return currentPageIndex == index
        ? Theme.of(context).colorScheme.indicatorActive
        : Theme.of(context).colorScheme.indicatorInActive;
  }
}
