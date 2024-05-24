import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:kwotes_trivia/components/buttons/dark_elevated_button.dart';
import 'package:kwotes_trivia/globals/utils.dart';
import 'package:lottie/lottie.dart';

class EndView extends StatelessWidget {
  const EndView({
    super.key,
    this.totalQuestionCount = 5,
    this.correctAnswerCount = 0,
    this.wrongAnswerCount = 0,
    this.onPlayAgain,
    this.onReturnHome,
  });

  /// Play again callback.
  final void Function()? onPlayAgain;

  /// Return home callback.
  final void Function()? onReturnHome;

  /// Total question count.
  final int totalQuestionCount;

  /// Correct answer count.
  final int correctAnswerCount;

  /// Wrong answer count.
  final int wrongAnswerCount;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(TablerIcons.confetti, size: 64.0),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          "Thank for playing!",
                          textAlign: TextAlign.center,
                          style: Utils.calligraphy.title(
                            textStyle: const TextStyle(
                              fontSize: 42.0,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          "You got $correctAnswerCount/$totalQuestionCount correct!",
                          textAlign: TextAlign.center,
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      DarkElevatedButton(
                        onPressed: onPlayAgain,
                        margin: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          "Play again",
                          style: Utils.calligraphy.body(
                            textStyle: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton(
                          onPressed: onReturnHome,
                          style: TextButton.styleFrom(
                            foregroundColor: foregroundColor?.withOpacity(0.6),
                            backgroundColor: foregroundColor?.withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            "Return home",
                            style: Utils.calligraphy.body(
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 24.0,
            left: 24.0,
            child: Lottie.asset(
              "assets/animations/tada.json",
              width: 200.0,
              height: 200.0,
            ),
          ),
          Positioned(
            top: 120.0,
            right: 0.0,
            child: Lottie.asset(
              "assets/animations/tada.json",
              width: 100.0,
              height: 100.0,
            ),
          ),
        ],
      ),
    );
  }
}
