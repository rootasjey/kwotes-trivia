import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:kwotes_trivia/components/buttons/circle_button.dart';
import 'package:kwotes_trivia/components/buttons/dark_elevated_button.dart';
import 'package:kwotes_trivia/globals/constants.dart';
import 'package:kwotes_trivia/globals/utils.dart';
import 'package:kwotes_trivia/types/author.dart';
import 'package:text_wrap_auto_size/text_wrap_auto_size.dart';

class AuthorAnswers extends StatelessWidget {
  const AuthorAnswers({
    super.key,
    required this.authorProposals,
    this.lastSelectedAnswer,
    this.canAnswer = true,
    this.lastAnswerIsCorrect = false,
    this.onSubmitAnswer,
  });

  /// Last selected answer.
  final Author? lastSelectedAnswer;

  /// True if the user can submit an answer.
  final bool canAnswer;

  /// True if last submitted answer is correct.
  final bool lastAnswerIsCorrect;

  /// Callback fired when an answer is submitted.
  final void Function(Author author)? onSubmitAnswer;

  /// List of author proposals.
  final List<Author> authorProposals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: authorProposals
            .map((Author author) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DarkElevatedButton(
                        onPressed: canAnswer
                            ? () => onSubmitAnswer?.call(author)
                            : null,
                        child: SizedBox(
                          height: 18.0,
                          width: MediaQuery.of(context).size.width - 72.0,
                          child: TextWrapAutoSize(
                            Text(
                              author.name,
                              style: Utils.calligraphy.body(
                                textStyle: const TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            maxFontSize: 18.0,
                            minFontSize: 8.0,
                          ),
                        ),
                        // child: Text(author.name),
                      ),
                    ),
                    if (lastSelectedAnswer != null &&
                        lastSelectedAnswer?.id == author.id)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleButton(
                          radius: 16.0,
                          backgroundColor: lastAnswerIsCorrect
                              ? Constants.colors.save
                              : Constants.colors.error,
                          icon: Icon(
                            lastAnswerIsCorrect
                                ? TablerIcons.check
                                : TablerIcons.x,
                            size: 14.0,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            })
            .toList()
            .animate(
              interval: 25.ms,
            )
            .fadeIn(
                duration: const Duration(milliseconds: 125),
                curve: Curves.decelerate)
            .slideY(
              begin: 0.4,
              end: 0.0,
            ),
      ),
    );
  }
}
