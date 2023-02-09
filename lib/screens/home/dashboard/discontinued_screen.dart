import 'dart:io';

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_link_text.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DiscontinuedScreen extends StatelessWidget {
  const DiscontinuedScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = Platform.isAndroid
        ? Strings.of(context).googleDiscontinuedPopupMessage
        : Strings.of(context).appleDiscontinuedPopupMessage;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.imagePaths.background),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: PwAppBar(
            title: Strings.of(context).discontinuedPopupTitle,
            color: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: Column(
                    children: [
                      VerticalSpacer.largeX4(),
                      PwLinkText(
                        text: message,
                        onTap: (String uri) {
                          launchUrlString(uri);
                        },
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      PwPrimaryButton(
                        child: PwText(Strings.of(context).okay),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      VerticalSpacer.largeX4(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
