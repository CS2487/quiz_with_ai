import 'question.dart';

class QuizResult {
  final String technologyId;
  final String technologyName;
  final List<QuestionResult> questionResults;
  final int totalQuestions;
  final int correctAnswers;
  final int easyCorrect;
  final int mediumCorrect;
  final int hardCorrect;
  final Duration timeTaken;
  final DateTime completedAt;
  String? aiAnalysis;
  String? skillLevel;
  List<String>? strengths;
  List<String>? weaknesses;

  QuizResult({
    required this.technologyId,
    required this.technologyName,
    required this.questionResults,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.easyCorrect,
    required this.mediumCorrect,
    required this.hardCorrect,
    required this.timeTaken,
    required this.completedAt,
    this.aiAnalysis,
    this.skillLevel,
    this.strengths,
    this.weaknesses,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }
}

class QuestionResult {
  final Question question;
  final List<int> userAnswers;
  final bool isCorrect;

  QuestionResult({
    required this.question,
    required this.userAnswers,
    required this.isCorrect,
  });
}
