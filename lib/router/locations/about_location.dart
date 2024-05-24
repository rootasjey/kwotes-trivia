import "package:beamer/beamer.dart";
import "package:flutter/widgets.dart";

class AboutLocation extends BeamLocation<BeamState> {
  static const String aboutUsRoute = "/about-us";
  static const String changelogRoute = "/changelog";
  static const String creditsRoute = "/credits";
  static const String tosRoute = "/privacy";

  @override
  List<String> get pathPatterns => [
        aboutUsRoute,
        changelogRoute,
        creditsRoute,
        tosRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [];
  }
}
