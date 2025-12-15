class AppConstants {
  static const String appName = 'Programming Quiz';
  static const int questionsPerQuiz = 30;
  static const int easyQuestions = 10;
  static const int mediumQuestions = 10;
  static const int hardQuestions = 10;
  static const int defaultTimerSeconds = 30;
  static const String apiBaseUrl = 'http://localhost:3000';
}

enum Difficulty { beginner, intermediate, advanced }

enum QuestionDifficulty { easy, medium, hard }

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  String get color {
    switch (this) {
      case Difficulty.beginner:
        return '4CAF50';
      case Difficulty.intermediate:
        return 'FF9800';
      case Difficulty.advanced:
        return 'F44336';
    }
  }
}
