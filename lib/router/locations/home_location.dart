import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:kwotes_trivia/screens/home/app_location_container.dart";
import "package:kwotes_trivia/screens/home/home_page.dart";
import "package:kwotes_trivia/screens/home/play_page.dart";

class HomeLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/";

  /// Dashboard location for deep navigation.
  static const String dashboardRoute = "/d/*";

  /// Home location for deep navigation.
  static const String homeRoute = "/h/*";

  /// Search location for deep navigation.
  static const String searchRoute = "/s/*";

  /// Settings location for deep navigation.
  static const String settingsRoute = "/settings/*";

  /// Premium location for deep navigation.
  static const String premiumRoute = "/premium/*";

  /// Image location.
  static const String imageRoute = "/image/*";

  /// Image author location.
  static const String imageAuthorRoute = "/image/author/:authorId";

  /// Image reference location.
  static const String imageReferenceRoute = "/image/reference/:referenceId";

  @override
  List<Pattern> get pathPatterns => [
        dashboardRoute,
        homeRoute,
        route,
        searchRoute,
        settingsRoute,
        imageRoute,
        imageAuthorRoute,
        imageReferenceRoute,
        premiumRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const AppLocationContainer(),
        key: const ValueKey(route),
        title: "page_title.home".tr(),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }

  String extractImageUrl() {
    if (state.routeState == null) {
      return "";
    }

    final Map routeState = state.routeState as Map;
    return routeState["image-url"] ?? "";
  }

  String extractHeroTag() {
    if (state.routeState == null) {
      return "";
    }

    final Map routeState = state.routeState as Map;
    return routeState["hero-tag"] ?? "";
  }

  double extractInitScale() {
    if (state.routeState == null) {
      return 0.2;
    }

    final Map routeState = state.routeState as Map;
    return routeState["init-scale"] ?? 0.2;
  }
}

class HomeContentLocation extends BeamLocation<BeamState> {
  HomeContentLocation(BeamState? state) : super(state?.routeInformation);

  /// Main root value for this location.
  static const String route = "/h";

  /// Play route location.
  static const String playRoute = "$route/play";

  /// Author route location.
  static const String authorRoute = "$route/author/:authorId";

  /// Author's quotes route location.
  static const String authorQuotesRoute = "$authorRoute/quotes";

  /// Author's single quote route location.
  /// e.g. `/h/author/authorId/quotes/quoteId`
  /// Useful to keep previous author page(s) below this one.
  static const String authorQuoteRoute = "$authorRoute/quotes/:quoteId";

  /// Edit author route location.
  static const String editAuthorRoute = "$route/edit/author/:authorId";

  /// Edit quote route location.
  static const String editQuoteRoute = "$route/edit/quote/:quoteId";

  /// Edit reference route location.
  static const String editReferenceRoute = "$route/edit/reference/:referenceId";

  /// Quote route location.
  static const String quoteRoute = "$route/quote/:quoteId";

  /// Reference route location.
  static const String referenceRoute = "$route/reference/:referenceId";

  /// Reference's quotes route location.
  static const String referenceQuotesRoute = "$referenceRoute/quotes";

  /// Reference's single quote route location.
  /// e.g. `/h/reference/authorId/quotes/quoteId`
  /// Useful to keep previous reference page(s) below this one.
  static const String referenceQuoteRoute = "$referenceRoute/quotes/:quoteId";

  /// Topic route location for home.
  static const String topicRoute = "$route/topic/:topicName";

  /// Quote route location on top of topic page.
  static const String topicQuoteRoute = "$topicRoute/quote/:quoteId";

  @override
  List<String> get pathPatterns => [
        editQuoteRoute,
        authorRoute,
        authorQuotesRoute,
        authorQuoteRoute,
        editAuthorRoute,
        editReferenceRoute,
        quoteRoute,
        referenceRoute,
        referenceQuotesRoute,
        referenceQuoteRoute,
        topicRoute,
        topicQuoteRoute,
        playRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const HomePage(),
        key: const ValueKey(route),
        title: "page_title.home".tr(),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains(playRoute.split("/").last))
        const BeamPage(
          child: PlayPage(),
          key: ValueKey(playRoute),
          type: BeamPageType.fadeTransition,
        ),
    ];
  }

  /// Extract author name from route state.
  String extractAuthorName(Object? routeState) {
    return routeState is Map ? routeState["authorName"] ?? "" : "";
  }

  /// Extract reference name from route state.
  String extractReferenceName(Object? routeState) {
    return routeState is Map ? routeState["referenceName"] ?? "" : "";
  }

  /// Extract topic name from route state.
  String extractTopicName(Object? routeState) {
    return routeState is Map ? routeState["topicName"] ?? "" : "";
  }

  /// Get quote page title from route state.
  String getQuotePageTitle(Object? routeState) {
    final String quoteName =
        routeState is Map ? routeState["quoteName"] ?? "" : "";

    if (quoteName.isEmpty) {
      return "page_title.quote".tr();
    }

    return "page_title.any".tr(
      args: [quoteName],
    );
  }
}
