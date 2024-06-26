import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes_trivia/globals/utils.dart";
import "package:kwotes_trivia/router/locations/home_location.dart";
import "package:kwotes_trivia/screens/not_found_page.dart";
import "package:kwotes_trivia/types/author.dart";
import "package:kwotes_trivia/types/enums/enum_frame_border_style.dart";
import "package:kwotes_trivia/types/quote.dart";
import "package:kwotes_trivia/types/quote_list.dart";
import "package:kwotes_trivia/types/reference.dart";

/// Helper class which contains additional navigation states.
class NavigationStateHelper {
  /// Selected author and passed through author page.
  static Author author = Author.empty();

  /// Show quote page in fullscreen (hiding the navigation bar) if true.
  /// We need this property on top of the local storage
  /// in order to syncronously know where to navigate (with the router).
  static bool fullscreenQuotePage = true;

  /// Is the current device an iPad.
  /// It's an iPad if true.
  /// This will avoid having delay when retrieving value from async API.
  static bool isIpad = false;

  /// Hide duplicated actions (e.g. [close], [copy]) on quote page,
  /// if this is true.
  static bool minimalQuoteActions = false;

  /// Show header page options (e.g. language) if true.
  static bool showHeaderPageOptions = true;

  /// App frame border style.
  static EnumFrameBorderStyle frameBorderStyle = EnumFrameBorderStyle.discrete;

  /// Current home page index (useful on mobile screen size).
  /// 0: home, 1: search, 2: dashboard.
  /// This will avoid having delay when retrieving value from local storage.
  static int homePageTabIndex = 0;

  /// Random quotes for home page.
  static List<Quote> randomQuotes = [];

  /// Latest added authors.
  static List<Author> latestAddedAuthors = [];

  /// Latest added references.
  static List<Reference> latestAddedReferences = [];

  /// Selected reference and passed through reference page.
  static Reference reference = Reference.empty();

  /// Selected quote and passed through quote page.
  static Quote quote = Quote.empty();

  /// Selected quote list and passed through quote list page.
  static QuoteList quoteList = QuoteList.empty();

  /// Last random quote language.
  /// Useful for fetching new random quotes after a language change.
  static String lastRandomQuoteLanguage = "en";

  /// Last topic name.
  static String lastTopicName = "";

  /// Search value.
  /// This value will be passed to the search page on navigation.
  /// Thus keeping context when navigating back and forth result pages.
  static String searchValue = "";

  /// Initial browser url.
  /// Necesarry to set app locale somewhere where we've access to a `context`.
  /// We cannot set it in the `main` method because the `context`
  /// is not available there.
  static String initialBrowserUrl = "";

  /// Prefill the login input with this value if it is not empty.
  /// Used on signin or signup page.
  /// ----------------------------------
  /// Case scenario: user start typing in the login input form and then
  /// they want to create a new account.
  static String userEmailInput = "";

  /// Prefill the password input with this value if it is not empty.
  /// Used on signin or signup page.
  /// ----------------------------------
  /// Case scenario: user start typing in the password input form and then
  /// they want to create a new account.
  static String userPasswordInput = "";

  /// Feedback message body.
  static String feedbackMessageBody = "";

  /// Beamer key to navigate sub-locations.
  static GlobalKey<BeamerState> homeBeamerKey = GlobalKey<BeamerState>(
    debugLabel: "home",
  );

  /// Beamer delegate to navigate home sub-locations.
  /// NOTE: Create delegate outside build method in order to avoid state issues.
  static BeamerDelegate homeRouterDelegate = BeamerDelegate(
    initialPath: HomeContentLocation.route,
    locationBuilder: BeamerLocationBuilder(beamLocations: [
      HomeContentLocation(BeamState.fromUriString(HomeContentLocation.route)),
    ]),
    notFoundPage: BeamPage(
      child: const NotFoundPage(),
      key: const ValueKey("notFoundPage-home"),
      type: BeamPageType.fadeTransition,
      title: "page_title.not_found".tr(),
    ),
  );

  /// Root navigation context.
  /// Useful to pop settings bottom sheet.
  static BuildContext? rootContext;

  /// Bottom sheet scroll controller.
  static ScrollController? bottomSheetScrollController;

  /// Initialize initial tab index.
  static Future<void> initInitialTabIndex({
    required String initialUrl,
    int? lastSavedIndex,
  }) async {
    if (initialUrl.contains("/h")) {
      homePageTabIndex = 0;
      return;
    }
    if (initialUrl.contains("/s")) {
      homePageTabIndex = 1;
      return;
    }
    if (initialUrl.contains("/d")) {
      homePageTabIndex = 2;
      return;
    }

    homePageTabIndex = lastSavedIndex ?? 0;
  }

  static Future<void> navigateBackToLastRoot(BuildContext context) async {
    if (!context.mounted) return;

    final int tabIndex = await Utils.vault.getHomePageTabIndex();
    String routeTab = "/h";
    switch (tabIndex) {
      case 0:
        routeTab = "/h";
        break;
      case 1:
        routeTab = "/s";
        break;
      case 2:
        routeTab = "/d";
        break;
      default:
        routeTab = "/h";
    }

    if (!context.mounted) return;
    Beamer.of(context, root: true).beamToNamed(routeTab);
  }
}
