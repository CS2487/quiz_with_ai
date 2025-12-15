import '../../../../core/constants/app_constants.dart';

class Question {
  final String id;
  final String technologyId;
  final String questionText;
  final String? codeSnippet;
  final List<String> options;
  final List<int> correctAnswers;
  final QuestionDifficulty difficulty;
  final String explanation;

  Question({
    required this.id,
    required this.technologyId,
    required this.questionText,
    this.codeSnippet,
    required this.options,
    required this.correctAnswers,
    required this.difficulty,
    required this.explanation,
  });

  bool get isMultipleChoice => correctAnswers.length > 1;

  bool checkAnswer(List<int> userAnswers) {
    if (userAnswers.length != correctAnswers.length) return false;
    final sortedUser = List<int>.from(userAnswers)..sort();
    final sortedCorrect = List<int>.from(correctAnswers)..sort();
    for (int i = 0; i < sortedUser.length; i++) {
      if (sortedUser[i] != sortedCorrect[i]) return false;
    }
    return true;
  }
}
