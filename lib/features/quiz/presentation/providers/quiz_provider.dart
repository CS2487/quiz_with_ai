import 'dart:math';
import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/question_bank.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_result.dart';

enum QuizState { initial, loading, inProgress, completed, error }

class QuizProvider {
  final QuestionBank _questionBank = QuestionBank();
  final Random _random = Random();

  QuizState _state = QuizState.initial;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  Map<int, List<int>> _userAnswers = {};
  String _currentTechnologyId = '';
  String _currentTechnologyName = '';
  DateTime? _startTime;
  int _timerSeconds = AppConstants.defaultTimerSeconds;
  bool _timerEnabled = true;

  QuizState get state => _state;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Question? get currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;
  Map<int, List<int>> get userAnswers => _userAnswers;
  String get currentTechnologyId => _currentTechnologyId;
  String get currentTechnologyName => _currentTechnologyName;
  int get timerSeconds => _timerSeconds;
  bool get timerEnabled => _timerEnabled;
  double get progress =>
      _questions.isNotEmpty ? (_currentQuestionIndex + 1) / _questions.length : 0;

  void startQuiz(String technologyId, String technologyName) {
    _state = QuizState.loading;
    _currentTechnologyId = technologyId;
    _currentTechnologyName = technologyName;
    _currentQuestionIndex = 0;
    _userAnswers = {};
    _startTime = DateTime.now();

    final allQuestions = _questionBank.getQuestionsForTechnology(technologyId);

    final easyQuestions = allQuestions
        .where((q) => q.difficulty == QuestionDifficulty.easy)
        .toList();
    final mediumQuestions = allQuestions
        .where((q) => q.difficulty == QuestionDifficulty.medium)
        .toList();
    final hardQuestions = allQuestions
        .where((q) => q.difficulty == QuestionDifficulty.hard)
        .toList();

    easyQuestions.shuffle(_random);
    mediumQuestions.shuffle(_random);
    hardQuestions.shuffle(_random);

    _questions = [
      ...easyQuestions.take(AppConstants.easyQuestions),
      ...mediumQuestions.take(AppConstants.mediumQuestions),
      ...hardQuestions.take(AppConstants.hardQuestions),
    ];

    _questions.shuffle(_random);
    _state = QuizState.inProgress;
  }

  void selectAnswer(int questionIndex, int answerIndex) {
    if (!_userAnswers.containsKey(questionIndex)) {
      _userAnswers[questionIndex] = [];
    }

    final question = _questions[questionIndex];
    if (question.isMultipleChoice) {
      if (_userAnswers[questionIndex]!.contains(answerIndex)) {
        _userAnswers[questionIndex]!.remove(answerIndex);
      } else {
        _userAnswers[questionIndex]!.add(answerIndex);
      }
    } else {
      _userAnswers[questionIndex] = [answerIndex];
    }
  }

  bool isAnswerSelected(int questionIndex, int answerIndex) {
    return _userAnswers[questionIndex]?.contains(answerIndex) ?? false;
  }

  bool hasAnsweredCurrentQuestion() {
    return _userAnswers.containsKey(_currentQuestionIndex) &&
        _userAnswers[_currentQuestionIndex]!.isNotEmpty;
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
    }
  }

  void setTimerEnabled(bool enabled) {
    _timerEnabled = enabled;
  }

  void resetTimer() {
    _timerSeconds = AppConstants.defaultTimerSeconds;
  }

  void decrementTimer() {
    if (_timerSeconds > 0) {
      _timerSeconds--;
    }
  }

  QuizResult finishQuiz() {
    _state = QuizState.completed;
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(_startTime ?? endTime);

    int correctAnswers = 0;
    int easyCorrect = 0;
    int mediumCorrect = 0;
    int hardCorrect = 0;

    List<QuestionResult> questionResults = [];

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _userAnswers[i] ?? [];
      final isCorrect = question.checkAnswer(userAnswer);

      if (isCorrect) {
        correctAnswers++;
        switch (question.difficulty) {
          case QuestionDifficulty.easy:
            easyCorrect++;
            break;
          case QuestionDifficulty.medium:
            mediumCorrect++;
            break;
          case QuestionDifficulty.hard:
            hardCorrect++;
            break;
        }
      }

      questionResults.add(QuestionResult(
        question: question,
        userAnswers: userAnswer,
        isCorrect: isCorrect,
      ));
    }

    return QuizResult(
      technologyId: _currentTechnologyId,
      technologyName: _currentTechnologyName,
      questionResults: questionResults,
      totalQuestions: _questions.length,
      correctAnswers: correctAnswers,
      easyCorrect: easyCorrect,
      mediumCorrect: mediumCorrect,
      hardCorrect: hardCorrect,
      timeTaken: timeTaken,
      completedAt: endTime,
    );
  }

  void reset() {
    _state = QuizState.initial;
    _questions = [];
    _currentQuestionIndex = 0;
    _userAnswers = {};
    _currentTechnologyId = '';
    _currentTechnologyName = '';
    _startTime = null;
    _timerSeconds = AppConstants.defaultTimerSeconds;
  }
}
