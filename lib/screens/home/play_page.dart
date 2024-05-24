import "package:animated_text_kit/animated_text_kit.dart";
import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes_trivia/actions/quote_actions.dart";
import "package:kwotes_trivia/components/buttons/circle_button.dart";
import "package:kwotes_trivia/components/buttons/dark_elevated_button.dart";
import "package:kwotes_trivia/components/loading_view.dart";
import "package:kwotes_trivia/globals/constants.dart";
import "package:kwotes_trivia/globals/utils.dart";
import "package:kwotes_trivia/router/locations/home_location.dart";
import "package:kwotes_trivia/router/navigation_state_helper.dart";
import "package:kwotes_trivia/screens/home/author_answers.dart";
import "package:kwotes_trivia/screens/home/correct_answer_hint.dart";
import "package:kwotes_trivia/screens/home/end_view.dart";
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
import "package:lottie/lottie.dart";
import "package:url_launcher/url_launcher.dart";
import "package:vibration/vibration.dart";
import "package:wave_divider/wave_divider.dart";

class PlayPage extends StatefulWidget {
  const PlayPage({
    super.key,
  });

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> with UiLoggy {
  /// False if the user has already answered.
  /// Used to disabled answser buttons.
  bool _canAnswer = true;

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Selected home category.
  // EnumHomeCategory _selectedCategory = EnumHomeCategory.quotes;

  /// Quote amount to fetch.
  final int _maxQuoteCount = 16;

  /// Current question number.
  int _currentQuestion = 1;

  /// The game ends after this amount of questions.
  final int _maxQuestions = 5;

  /// Correct answer count.
  int _correctAnswerCount = 0;

  /// Wrong answer count.
  int _wrongAnswerCount = 0;

  /// True if last answer was correct.
  bool _lastAnswerIsCorrect = false;

  /// Last selected author answer.
  Author _lastSelectedAnswer = Author.empty();

  /// Display this pool of (author) proposals.
  final List<Author> _authorProposals = [];

  /// Display this pool of (reference) proposals.
  final List<Reference> _referenceProposals = [];

  /// Displayed quote.
  /// The user has to find the correct author or reference of this quote.
  Quote _heroQuote = Quote.empty();

  @override
  void initState() {
    super.initState();
    fetchRandomQuotes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final List<Quote> quotes = NavigationStateHelper.randomQuotes;
    // final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    if (quotes.isEmpty) {
      return LoadingView.scaffold();
    }

    if (_currentQuestion > _maxQuestions) {
      return EndView(
        totalQuestionCount: _maxQuestions,
        correctAnswerCount: _correctAnswerCount,
        wrongAnswerCount: _wrongAnswerCount,
        onPlayAgain: onPlayAgain,
        onReturnHome: onReturnHome,
      );
    }

    final Color accentColor = _heroQuote.topics.isNotEmpty
        ? Constants.colors.getColorFromTopicName(
            context,
            topicName: _heroQuote.topics.first,
          )
        : Colors.amber;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(36.0),
                  sliver: SliverList.list(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "$_currentQuestion/$_maxQuestions",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: foregroundColor?.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              if (!_canAnswer)
                                Text(
                                  _lastAnswerIsCorrect
                                      ? " • Good Answer!"
                                      : " • Bad Answer :(",
                                  style: Utils.calligraphy.body(
                                    textStyle: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      // color: foregroundColor?.withOpacity(0.6),
                                      color: _lastAnswerIsCorrect
                                          ? Constants.colors.save
                                          : Constants.colors.error,
                                    ),
                                  ),
                                )
                                    .animate()
                                    .slideX(
                                        begin: 0.4,
                                        end: 0.0,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.decelerate)
                                    .fadeIn(
                                      begin: 0.6,
                                    ),
                            ],
                          ),
                          CircleButton(
                            onTap: onCloseGame,
                            radius: 14.0,
                            tooltip: "close".tr(),
                            icon: const Icon(
                              TablerIcons.x,
                              size: 18.0,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          children: [
                            Text(
                              "Who said?",
                              style: Utils.calligraphy.body(
                                textStyle: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Card(
                              elevation: 0.0,
                              margin: const EdgeInsets.only(top: 12.0),
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28.0,
                                      vertical: 6.0,
                                    ),
                                    child: AnimatedTextKit(
                                      isRepeatingAnimation: false,
                                      displayFullTextOnTap: true,
                                      pause: const Duration(milliseconds: 0),
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          _heroQuote.name,
                                          speed: 10.ms,
                                          textStyle: Utils.calligraphy.body(
                                            textStyle: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                              color: foregroundColor
                                                  ?.withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.0,
                                    left: 0.0,
                                    child: Transform.flip(
                                      flipX: true,
                                      child: Icon(
                                        TablerIcons.quote,
                                        color: accentColor,
                                      ),
                                    )
                                        .animate()
                                        .scale(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1.0, 1.0),
                                        )
                                        .fadeIn(
                                          begin: 0.0,
                                        ),
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    right: 0.0,
                                    child: Transform.flip(
                                      flipX: false,
                                      child: Icon(
                                        TablerIcons.quote,
                                        color: accentColor,
                                      ),
                                    )
                                        .animate()
                                        .scale(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1.0, 1.0),
                                        )
                                        .fadeIn(
                                          begin: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const WaveDivider(
                        padding: EdgeInsets.only(top: 24.0),
                      ),
                      CorrectAnswerHint(
                        quote: _heroQuote,
                        show: !_canAnswer && !_lastAnswerIsCorrect,
                        margin: const EdgeInsets.only(top: 16.0),
                      ),
                      AuthorAnswers(
                        canAnswer: _canAnswer,
                        authorProposals: _authorProposals,
                        lastAnswerIsCorrect: _lastAnswerIsCorrect,
                        lastSelectedAnswer: _lastSelectedAnswer,
                        onSubmitAnswer: onSubmitAnswer,
                      ),
                      if (!_canAnswer)
                        DarkElevatedButton(
                          onPressed: onPrepareNextQuestion,
                          margin: const EdgeInsets.only(top: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentQuestion == _maxQuestions
                                    ? "see_results".tr()
                                    : "next".tr(),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child:
                                    Icon(TablerIcons.arrow_right, size: 18.0),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Lottie.asset(
              "assets/animations/fireworks.json",
              width: 200.0,
              height: 200.0,
              repeat: false,
              animate: !_canAnswer && _lastAnswerIsCorrect,
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
    // if (await shouldSkipFetch(forceRefresh: forceRefresh)) {
    //   _subRandomQuotes.isEmpty
    //       ? setState(
    //           () => _subRandomQuotes.addAll(
    //             NavigationStateHelper.randomQuotes.sublist(1),
    //           ),
    //         )
    //       : null;
    //   return;
    // }

    final String currentLanguage = await getLanguage();

    setState(() {
      _pageState = _pageState != EnumPageState.loading
          ? EnumPageState.loadingRandomQuotes
          : EnumPageState.loading;

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
        Quote quote = Quote.fromMap(data);
        if (quote.author.id == Constants.skippingAuthor ||
            quote.author.id == "u7mqAyOVwpVGWz4sTECr" ||
            quote.author.id == "TySUhQPqndIkiVHWVYq1") {
          continue;
        }

        final Author? author = await fetchAuthor(quote.author.id);
        if (author != null) {
          quote = quote.copyWith(author: author);

          if (_heroQuote.id.isEmpty) {
            _heroQuote = quote;
            _authorProposals.add(author);
          } else if (_authorProposals.length < 3) {
            _authorProposals.add(author);
          }
        }

        NavigationStateHelper.randomQuotes.add(quote);
      }

      _authorProposals.shuffle();

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

  /// Submit an answer.
  void onSubmitAnswer(Author author) {
    if (!_canAnswer) {
      return;
    }

    _canAnswer = false;
    _lastSelectedAnswer = author;

    Vibration.hasVibrator().then(
      (bool? hasVibrator) {
        if (!hasVibrator!) return;
        Vibration.vibrate(duration: 25, amplitude: 25);
      },
    );

    if (author.id == _heroQuote.author.id) {
      _correctAnswerCount++;
      _lastAnswerIsCorrect = true;
      setState(() {});
      // Utils.graphic.showSnackbar(
      //   context,
      //   message: "Good Answer!",
      // );
      return;
    }

    _wrongAnswerCount++;
    _lastAnswerIsCorrect = false;
    setState(() {});
    // Utils.graphic.showSnackbar(
    //   context,
    //   message: "Sorry, ${_heroQuote.author.name} was the right answer. ",
    // );
  }

  void onPrepareNextQuestion() {
    setState(() {
      _heroQuote = Quote.empty();
      _canAnswer = true;
      _currentQuestion += 1;
      _authorProposals.clear();
      _referenceProposals.clear();
      refetchRandomQuotes();
    });
  }

  void onCloseGame() {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.route,
    );
  }

  void onPlayAgain() {
    setState(() {
      _heroQuote = Quote.empty();
      _canAnswer = true;
      _lastSelectedAnswer = Author.empty();
      _lastAnswerIsCorrect = false;
      _authorProposals.clear();
      _referenceProposals.clear();

      _correctAnswerCount = 0;
      _wrongAnswerCount = 0;
      _currentQuestion = 1;
      refetchRandomQuotes();
    });
  }

  void onReturnHome() {
    Beamer.of(context).beamToNamed(
      HomeContentLocation.route,
    );
  }
}
