import 'package:provenance_wallet/common/pw_design.dart';

class PageIndicator extends StatelessWidget {
  PageIndicator({
    required this.currentPageIndex,
  });
  // TODO: Make sure that these colors make it into the theme.
  final Color _active = Color(0xFFF3F4F6);
  final Color _inActive = Color(0xFF8B90A7);

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
              color: _getColor(0),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _getColor(0),
          ),
        ),
        HorizontalSpacer.small(),
        Container(
          height: 4,
          width: 30,
          decoration: BoxDecoration(
            border: Border.all(
              color: _getColor(1),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _getColor(1),
          ),
        ),
        HorizontalSpacer.small(),
        Container(
          height: 4,
          width: 30,
          decoration: BoxDecoration(
            border: Border.all(
              color: _getColor(2),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _getColor(2),
          ),
        ),
      ],
    );
  }

  Color _getColor(int index) {
    return currentPageIndex == index ? _active : _inActive;
  }
}
