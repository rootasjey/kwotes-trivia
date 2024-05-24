import "dart:math";

import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes_trivia/components/buttons/circle_button.dart";
import "package:kwotes_trivia/components/buttons/menu_navigation_item.dart";
import "package:kwotes_trivia/globals/constants.dart";
import "package:kwotes_trivia/globals/utils.dart";
import "package:kwotes_trivia/router/locations/home_location.dart";
import "package:kwotes_trivia/router/navigation_state_helper.dart";
import "package:kwotes_trivia/screens/home/home_navigation_page.dart";
import "package:kwotes_trivia/types/enums/enum_signal_id.dart";
import "package:kwotes_trivia/types/intents/dashboard_intent.dart";
import "package:kwotes_trivia/types/intents/escape_intent.dart";
import "package:kwotes_trivia/types/intents/home_intent.dart";
import "package:kwotes_trivia/types/intents/search_intent.dart";

class AppLocationContainer extends StatefulWidget {
  /// App container with deep locations and navigation bar.
  const AppLocationContainer({
    super.key,
  });

  @override
  State<AppLocationContainer> createState() => _AppLocationContainerState();
}

class _AppLocationContainerState extends State<AppLocationContainer> {
  /// Whether navigation bar is visible.
  bool _navigationBarVisible = true;

  /// Animation target.
  double _target = 0.0;

  /// Previous brightness.
  Brightness? _previousBrightness;

  /// Current page index.
  int _currentIndex = 0;

  /// List of widget children.
  final List<StatefulWidget> _widgetChildren = [
    const HomeNavigationPage(),
  ];

  /// Keyboard shortcuts definition.
  final Map<SingleActivator, Intent> _shortcuts = {
    const SingleActivator(
      LogicalKeyboardKey.digit3,
      control: true,
    ): const DashboardIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit1,
      control: true,
    ): const HomeIntent(),
    const SingleActivator(
      LogicalKeyboardKey.digit2,
      control: true,
    ): const SearchIntent(),
    const SingleActivator(
      LogicalKeyboardKey.escape,
    ): const EscapeIntent(),
  };

  @override
  void initState() {
    super.initState();
    initProps();
  }

  @override
  Widget build(BuildContext context) {
    adaptUiOverlayStyle();
    final bool isMobile = Utils.measurements.isMobileSize(context);
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final Signal<bool> signalNavigationBar =
        context.get<Signal<bool>>(EnumSignalId.navigationBar);

    final Map<Type, CallbackAction<Intent>> actions = {
      EscapeIntent: CallbackAction<EscapeIntent>(
        onInvoke: onEscapeShortcut,
      ),
      DashboardIntent: CallbackAction<DashboardIntent>(
        onInvoke: onDashboardShortcut,
      ),
      SearchIntent: CallbackAction<SearchIntent>(
        onInvoke: onSearchShortcut,
      ),
      HomeIntent: CallbackAction<HomeIntent>(
        onInvoke: onHomeShortcut,
      ),
    };

    if (isMobile) {
      return Focus(
        autofocus: true,
        child: Shortcuts(
          shortcuts: _shortcuts,
          child: Actions(
            actions: actions,
            child: Scaffold(
              body: _widgetChildren[_currentIndex],
            ),
          ),
        ),
      );
    }

    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: actions,
        child: Scaffold(
          body: Stack(
            children: [
              Material(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                clipBehavior: Clip.antiAlias,
                child: _widgetChildren[_currentIndex],
              ),
              Positioned(
                bottom: 12.0,
                left: 0.0,
                right: 0.0,
                child: SignalBuilder(
                  signal: signalNavigationBar,
                  builder: (BuildContext context, bool show, Widget? child) {
                    if (show) {
                      return child ?? const SizedBox.shrink();
                    }

                    return const SizedBox.shrink();
                  },
                  child: Column(
                    children: [
                      if (_navigationBarVisible)
                        Container(
                          width: 240.0,
                          height: 58.0,
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          child: Material(
                            color: isDarkTheme ? Colors.black87 : Colors.white,
                            elevation: isDarkTheme ? 4.0 : 6.0,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(54.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MenuNavigationItem(
                                  index: 0,
                                  icon: const Icon(TablerIcons.home),
                                  onTap: onTapBottomBarItem,
                                  selectedColor: Constants.colors.home,
                                  selected: _currentIndex == 0,
                                  tooltip: "home".tr(),
                                ),
                                MenuNavigationItem(
                                  icon: const Icon(TablerIcons.search),
                                  index: 1,
                                  onTap: onTapBottomBarItem,
                                  selected: _currentIndex == 1,
                                  selectedColor: Constants.colors.search,
                                  tooltip: "search.name".tr(),
                                ),
                                MenuNavigationItem(
                                  icon: const Icon(TablerIcons.notebook),
                                  index: 2,
                                  onTap: onTapBottomBarItem,
                                  selected: _currentIndex == 2,
                                  selectedColor: Constants.colors.delete,
                                  tooltip: "dashboard".tr(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      CircleButton(
                        radius: 14.0,
                        icon: const Icon(
                          TablerIcons.chevron_down,
                          size: 14.0,
                        )
                            .animate(target: _target)
                            .rotate(begin: 0.0, end: (pi / 4) * 0.64),
                        onTap: toggleNavigationBarVisibility,
                      ),
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

  /// Adapt UI overlay style on Android and iOS.
  void adaptUiOverlayStyle() {
    if (!Utils.graphic.isMobile()) {
      return;
    }

    final Brightness? currentBrightness =
        AdaptiveTheme.maybeOf(context)?.brightness;

    if (currentBrightness == null) {
      return;
    }

    if (currentBrightness == _previousBrightness) {
      return;
    }

    _previousBrightness = currentBrightness;

    final SystemUiOverlayStyle overlayStyle =
        currentBrightness == Brightness.dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent, // optional
                systemNavigationBarColor: Color.alphaBlend(
                  Colors.black26,
                  Constants.colors.dark,
                ),
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent, // optional
                systemNavigationBarColor: Colors.white,
                systemNavigationBarDividerColor: Colors.transparent,
              );

    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }

  /// Initialize page properties.
  void initProps() async {
    _currentIndex = NavigationStateHelper.homePageTabIndex;
    initBrowserUrlWithTab(_currentIndex);
  }

  /// Navigate back to root when tapping on already selected bottom bar item.
  void navigateBackToRoot(int index) {
    switch (index) {
      case 0:
        NavigationStateHelper.homeRouterDelegate.beamToNamed(
          NavigationStateHelper.homeRouterDelegate.initialPath,
        );
        break;
      default:
        break;
    }
  }

  /// Callback fired to navigate to dashboard page.
  Object? onDashboardShortcut(DashboardIntent intent) {
    onTapBottomBarItem(2);
    return null;
  }

  /// Callback fired to navigate back from shortcuts.
  Object? onEscapeShortcut(EscapeIntent intent) {
    Utils.passage.deepBack(context);
    return null;
  }

  /// Callback fired to navigate to home page.
  Object? onHomeShortcut(HomeIntent intent) {
    onTapBottomBarItem(0);
    return null;
  }

  /// Callback fired to navigate to search page.
  Object? onSearchShortcut(SearchIntent intent) {
    onTapBottomBarItem(1);
    return null;
  }

  /// Callback fired when bottom bar item is tapped.
  void onTapBottomBarItem(int index) {
    if (index == _currentIndex) {
      navigateBackToRoot(index);
    }

    setState(() => _currentIndex = index);
    NavigationStateHelper.homePageTabIndex = index;
    Utils.vault.setHomePageTabIndex(index);
    updateBrowserUrl(index);
  }

  /// Re-set the last route information of the nested beamer.
  /// Update browser url according to selected bottom bar item.
  void updateBrowserUrl(int index) {
    switch (index) {
      case 0:
        final RouteInformation routeInformation =
            NavigationStateHelper.homeRouterDelegate.currentConfiguration ??
                RouteInformation(uri: Uri(path: HomeContentLocation.route));

        Beamer.of(context).update(configuration: routeInformation);
        break;
      default:
        break;
    }
  }

  /// Initialize browser url according to selected bottom bar item.
  void initBrowserUrlWithTab(int currentIndex) {
    if (NavigationStateHelper.initialBrowserUrl != "/") {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final BeamerDelegate beamer = Beamer.of(context);
      switch (currentIndex) {
        case 0:
          const String path = HomeContentLocation.route;
          beamer.update(configuration: RouteInformation(uri: Uri(path: path)));
          break;
        default:
          break;
      }
    });
  }

  void toggleNavigationBarVisibility() {
    setState(() {
      _target = _target == 0.0 ? 1.0 : 0.0;
      _navigationBarVisible = !_navigationBarVisible;
    });
  }
}
