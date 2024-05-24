import 'package:flutter/material.dart';
import 'package:kwotes_trivia/globals/utils.dart';
import 'package:kwotes_trivia/types/quote.dart';

class CorrectAnswerHint extends StatelessWidget {
  const CorrectAnswerHint({
    super.key,
    required this.quote,
    this.show = true,
    this.margin = EdgeInsets.zero,
  });

  /// True if hint should be shown.
  final bool show;

  /// Hint margin.
  final EdgeInsets margin;

  /// Quote and associated answer.
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    // if (!show) {retur}
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: margin,
        height: show ? null : 0.0,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: "→ The correct answer is: ",
              ),
              TextSpan(
                text: quote.author.name,
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: foregroundColor?.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}
