import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes_trivia/actions/quote_actions.dart";
import "package:kwotes_trivia/components/buttons/brightness_button.dart";
import "package:kwotes_trivia/components/buttons/dark_elevated_button.dart";
import "package:kwotes_trivia/globals/constants.dart";
import "package:kwotes_trivia/globals/utils.dart";
import "package:kwotes_trivia/router/locations/home_location.dart";
import "package:kwotes_trivia/router/navigation_state_helper.dart";
import "package:kwotes_trivia/types/alias/json_alias.dart";
import "package:kwotes_trivia/types/author.dart";
import "package:kwotes_trivia/types/enums/enum_language_selection.dart";
import "package:kwotes_trivia/types/enums/enum_page_state.dart";
import "package:kwotes_trivia/types/firestore/document_snapshot_map.dart";
import "package:kwotes_trivia/types/firestore/query_doc_snap_map.dart";
import "package:kwotes_trivia/types/firestore/query_snap_map.dart";
import "package:kwotes_trivia/types/quote.dart";
import "package:kwotes_trivia/types/random_quote_document.dart";
import "package:kwotes_trivia/types/reference.dart";
import "package:loggy/loggy.dart";
import "package:url_launcher/url_launcher.dart";
import "package:vibration/vibration.dart";

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with UiLoggy {
  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Quote amount to fetch.
  final int _maxQuoteCount = 12;

  /// Amount of authors to fetch.
  final int _maxAuthorCount = 24;

  /// Amount of references to fetch.
  final int _maxReferenceCount = 24;

  /// Sub-list of random quotes.
  final List<Quote> _subRandomQuotes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final bool isMobileSize = Utils.measurements.isMobileSize(context);
    // final List<Quote> quotes = NavigationStateHelper.randomQuotes;
    // final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color? buttonBackgroundColor = foregroundColor?.withOpacity(0.025);

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(36.0),
              sliver: SliverList.list(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "",
                            children: const [
                              TextSpan(text: "Kwotes"),
                            ],
                            style: Utils.calligraphy.title(
                              textStyle: TextStyle(
                                fontSize: 42.0,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                                color: foregroundColor?.withOpacity(0.8),
                                shadows: const [
                                  Shadow(
                                    color: Colors.black12,
                                    blurRadius: 2.0,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Text.rich(
                          const TextSpan(
                            text: "",
                            children: [
                              TextSpan(text: "Trivia"),
                            ],
                          ),
                          style: Utils.calligraphy.title(
                            textStyle: TextStyle(
                              fontSize: 42.0,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                              color: foregroundColor?.withOpacity(0.8),
                              shadows: const [
                                Shadow(
                                  color: Colors.black12,
                                  blurRadius: 2.0,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Stack(
                      children: [
                        Transform.rotate(
                          angle: 0.1,
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Container(
                              width: 164.0,
                              height: 224.0,
                              foregroundDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  width: 2.0,
                                  color: foregroundColor ?? Colors.white,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const BrightnessButton(),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              buttonBackgroundColor,
                                          foregroundColor: foregroundColor,
                                        ),
                                        child: Text("signin.name".tr()),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              buttonBackgroundColor,
                                          foregroundColor: foregroundColor,
                                        ),
                                        child: Text("settings.name".tr()),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0.0,
                          child: Transform.rotate(
                            angle: -0.1,
                            child: Card(
                              elevation: 4.0,
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Container(
                                width: 164.0,
                                height: 224.0,
                                foregroundDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    width: 2.0,
                                    color: foregroundColor ?? Colors.white,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Find who said it",
                                        style: Utils.calligraphy.body4(
                                          textStyle: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Can you guess the author of the quote? "
                                        "For each kwote, choose the right author or reference.",
                                        style: Utils.calligraphy.body(
                                          textStyle: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w400,
                                            color: foregroundColor
                                                ?.withOpacity(0.4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Play with popular quotes from movies, tv shows & books.",
                    textAlign: TextAlign.center,
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        color: foregroundColor?.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: DarkElevatedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onPressed: onTapPlayButton,
                      child: Text(
                        "Play".tr(),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: foregroundColor?.withOpacity(0.6),
                      textStyle: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.0,
                        ),
                      ),
                      padding: const EdgeInsets.all(0.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      "How does it work?".tr(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fetches a specific author from their id.
  Future<Author?> fetchAuthor(String authorId) async {
    if (authorId.isEmpty) {
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("authors")
          .doc(authorId)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      data["id"] = snapshot.id;
      return Author.fromMap(data);
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  /// Fetches latest added authors.
  void fetchLatestAddedAuthors() async {
    setState(() => _pageState = EnumPageState.loading);

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("authors")
          .orderBy("created_at", descending: true)
          .limit(_maxAuthorCount)
          .get();

      if (snapshot.size == 0) {
        return;
      }

      for (final DocumentSnapshotMap doc in snapshot.docs) {
        final Json? data = doc.data();
        if (data == null) {
          continue;
        }

        data["id"] = doc.id;
        NavigationStateHelper.latestAddedAuthors.add(Author.fromMap(data));
      }

      setState(() => _pageState = EnumPageState.idle);
    } catch (error) {
      loggy.error(error);
    }
  }

  /// Fetches latest added references.
  void fetchLatestAddedReferences() async {
    setState(() => _pageState = EnumPageState.loading);

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("references")
          .orderBy("created_at", descending: true)
          .limit(_maxReferenceCount)
          .get();

      if (snapshot.size == 0) {
        return;
      }

      for (final DocumentSnapshotMap doc in snapshot.docs) {
        final Json? data = doc.data();
        if (data == null) {
          continue;
        }

        data["id"] = doc.id;
        final Reference reference = Reference.fromMap(data);
        NavigationStateHelper.latestAddedReferences.add(reference);
      }

      // setState(() {});
      setState(() => _pageState = EnumPageState.idle);
    } catch (error) {
      loggy.error(error);
    }
  }

  /// Gets current language.
  Future<String> getLanguage() async {
    final EnumLanguageSelection savedLanguage = await Utils.vault.getLanguage();
    if (Utils.linguistic.available().contains(savedLanguage)) {
      return savedLanguage.name;
    }

    return "en";
  }

  /// Fetches random quotes.
  Future<void> fetchRandomQuotes({bool forceRefresh = false}) async {
    if (await shouldSkipFetch(forceRefresh: forceRefresh)) {
      _subRandomQuotes.isEmpty
          ? setState(
              () => _subRandomQuotes.addAll(
                NavigationStateHelper.randomQuotes.sublist(1),
              ),
            )
          : null;
      return;
    }

    final String currentLanguage = await getLanguage();

    setState(() {
      _pageState = _pageState != EnumPageState.loading
          ? EnumPageState.loadingRandomQuotes
          : EnumPageState.loading;

      _subRandomQuotes.clear();
      NavigationStateHelper.randomQuotes.clear();
      NavigationStateHelper.lastRandomQuoteLanguage = currentLanguage;
    });

    try {
      final String language = await Utils.linguistic.getLanguage();
      final QuerySnapMap randomSnapshot = await FirebaseFirestore.instance
          .collection("randoms")
          .where("language", isEqualTo: language)
          .limit(1)
          .get();

      if (randomSnapshot.size == 0) {
        setState(() => _pageState = EnumPageState.idle);
        return;
      }

      final QueryDocSnapMap randomDocSnap = randomSnapshot.docs.first;
      final Json map = randomDocSnap.data();
      map["id"] = randomDocSnap.id;

      final RandomQuoteDocument randomQuoteDoc =
          RandomQuoteDocument.fromMap(map);

      randomQuoteDoc.items.shuffle();

      final List<String> items =
          randomQuoteDoc.items.take(_maxQuoteCount).toList();

      for (final String quoteId in items) {
        final DocumentSnapshotMap quoteDoc = await FirebaseFirestore.instance
            .collection("quotes")
            .doc(quoteId)
            .get();

        final Json? data = quoteDoc.data();
        if (data == null) {
          continue;
        }

        data["id"] = quoteDoc.id;
        final Quote quote = Quote.fromMap(data);
        if (quote.author.id == Constants.skippingAuthor) {
          continue;
        }
        NavigationStateHelper.randomQuotes.add(quote);
      }

      _subRandomQuotes.addAll(NavigationStateHelper.randomQuotes.sublist(1));

      if (!mounted) return;
      setState(() => _pageState = EnumPageState.idle);
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Fetches a specific reference from its id.
  Future<Reference?> fetchReference(String referenceId) async {
    if (referenceId.isEmpty) {
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("references")
          .doc(referenceId)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      data["id"] = snapshot.id;
      return Reference.fromMap(data);
    } catch (error) {
      loggy.error(error);
      return null;
    }
  }

  /// Update application's language.
  void onChangeLanguage(EnumLanguageSelection locale) {
    fetchRandomQuotes();
  }

  void onCopyAuthorName(Author author) {
    Clipboard.setData(ClipboardData(text: author.name));
    Utils.graphic.showSnackbar(
      context,
      message: "author.copy.success.name".tr(),
    );
  }

  /// Copy a specific quote's name to the clipboard.
  void onCopyQuote(Quote quote) {
    QuoteActions.copyQuote(quote);
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyQuoteSnackbar(context, isMobileSize: isMobileSize);
  }

  /// Copy a specific quote's url to the clipboard.
  void onCopyQuoteUrl(Quote quote) {
    QuoteActions.copyQuoteUrl(quote);
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    Utils.graphic.showCopyQuoteLinkSnackbar(
      context,
      isMobileSize: isMobileSize,
    );
  }

  /// Navigate to the quote page.
  void onTapQuote(Quote quote) {
    NavigationStateHelper.quote = quote;
    Beamer.of(context).beamToNamed(
      HomeContentLocation.quoteRoute.replaceFirst(":quoteId", quote.id),
      routeState: {
        "quoteName": quote.name,
      },
    );
  }

  /// Open projcet's GitHub page.
  void onTapGitHub() {
    launchUrl(Uri.parse(Constants.githubUrl));
  }

  /// Navigate to the author page.
  void onTapAuthor(Author author) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.authorRoute.replaceFirst(
        ":authorId",
        author.id,
      ),
      routeState: {
        "authorName": author.name,
      },
    );
  }

  /// Navigate to the reference page.
  void onTapReference(Reference reference) {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.referenceRoute.replaceFirst(
        ":referenceId",
        reference.id,
      ),
      routeState: {
        "referenceName": reference.name,
      },
    );
  }

  /// Refetches random quotes.
  Future<void> refetchRandomQuotes() {
    return fetchRandomQuotes(forceRefresh: true);
  }

  /// Checks if should skip fetching random quotes.
  Future<bool> shouldSkipFetch({bool forceRefresh = false}) async {
    final String currentLanguage = await getLanguage();
    final bool hasLanguageChanged =
        NavigationStateHelper.lastRandomQuoteLanguage != currentLanguage;

    return NavigationStateHelper.randomQuotes.isNotEmpty &&
        !hasLanguageChanged &&
        !forceRefresh;
  }

  void onToggleAppTheme() {
    AdaptiveTheme.of(context).toggleThemeMode();
    final AdaptiveThemeMode mode = AdaptiveTheme.of(context).mode;
    Utils.graphic.showSnackbar(
      context,
      message: "theme.${mode.modeName.toLowerCase()}".tr(),
    );
  }

  void onTapPlayButton() {
    Vibration.hasVibrator().then(
      (bool? hasVibrator) {
        if (!hasVibrator!) return;
        Vibration.vibrate(duration: 25, amplitude: 25);
      },
    );
    context.beamToNamed(HomeContentLocation.playRoute);
  }
}
