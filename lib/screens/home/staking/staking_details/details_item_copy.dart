import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

class DetailsItemCopy extends StatefulWidget {
  final String displayTitle;
  final String dataToCopy;
  final String snackBarTitle;

  const DetailsItemCopy({
    Key? key,
    required this.displayTitle,
    required this.dataToCopy,
    required this.snackBarTitle,
  }) : super(key: key);

  @override
  State<DetailsItemCopy> createState() => _DetailsItemCopyState();
}

class _DetailsItemCopyState extends State<DetailsItemCopy> {
  bool _isActive = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Spacing.large),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PwText(
                widget.displayTitle,
                color: PwColor.neutral200,
                style: PwTextStyle.footnote,
              ),
              if (_isActive)
                PwText(
                  widget.dataToCopy,
                  color: PwColor.neutral200,
                  style: PwTextStyle.footnote,
                ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    _isActive = !_isActive;
                  });
                },
                child: Row(
                  children: [
                    if (!_isActive)
                      PwText(
                        widget.dataToCopy.abbreviateAddress(),
                        color: PwColor.neutral200,
                        style: PwTextStyle.footnote,
                      ),
                    if (!_isActive) HorizontalSpacer.xSmall(),
                    PwText(
                      _isActive
                          ? Strings.stakingDetailsViewLess
                          : Strings.viewMore,
                      color: PwColor.neutral200,
                      style: PwTextStyle.footnote,
                      underline: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: widget.dataToCopy,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.snackBarTitle,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.neutral700,
                    ),
                  );
                },
                child: PwIcon(
                  PwIcons.copy,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
