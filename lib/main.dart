import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kwotes_trivia/app.dart';
import 'package:kwotes_trivia/firebase_options.dart';
import 'package:kwotes_trivia/globals/utils.dart';
import 'package:kwotes_trivia/router/app_routes.dart';
import 'package:kwotes_trivia/router/navigation_state_helper.dart';
import 'package:loggy/loggy.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString("google_fonts/OFL.txt");
    yield LicenseEntryWithLineBreaks(["google_fonts"], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Beamer.setPathUrlStrategy();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: "var.env");

  final String browserUrl = Uri.base.query.isEmpty
      ? Uri.base.path
      : "${Uri.base.path}?${Uri.base.query}";

  NavigationStateHelper.initialBrowserUrl = browserUrl;

  // Make sure that the initial route is kept correctly.
  if (kIsWeb) {
    appBeamerDelegate.setInitialRoutePath(RouteInformation(
      uri: Uri.parse(browserUrl),
    ));
  }

  final AdaptiveThemeMode? savedThemeMode = await AdaptiveTheme.getThemeMode();
  final int lastSavedTabIndex = await Utils.vault.getHomePageTabIndex();

  NavigationStateHelper.initInitialTabIndex(
    initialUrl: browserUrl,
    lastSavedIndex: lastSavedTabIndex,
  );
  if (!kIsWeb) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      await windowManager.ensureInitialized();

      windowManager.waitUntilReadyToShow(
        const WindowOptions(
          titleBarStyle: TitleBarStyle.hidden,
        ),
        () async => await windowManager.show(),
      );
    }
  }

  return runApp(
    EasyLocalization(
      path: "assets/translations",
      supportedLocales: const [Locale("en"), Locale("fr")],
      fallbackLocale: const Locale("en"),
      child: App(savedThemeMode: savedThemeMode),
    ),
  );
}
