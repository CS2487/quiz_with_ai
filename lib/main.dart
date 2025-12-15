import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/home/data/datasources/technology_datasource.dart';
import 'features/home/domain/entities/technology.dart';
import 'features/quiz/data/datasources/question_bank.dart';
import 'features/quiz/domain/entities/question.dart';
import 'features/quiz/domain/entities/quiz_result.dart';
import 'dart:math';

class ProgrammingQuizApp {
  final TechnologyDatasource _techDatasource = TechnologyDatasource();
  final QuestionBank _questionBank = QuestionBank();
  final Random _random = Random();

  List<Question> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  Map<int, List<int>> _userAnswers = {};
  String _currentTechId = '';
  String _currentTechName = '';
  DateTime? _startTime;
  Timer? _timer;
  int _timeRemaining = 30;
  bool _timerEnabled = true;

  void run() {
    _renderHomePage();
  }

  void _renderHomePage() {
    final container = querySelector('#app')!;
    final technologies = _techDatasource.getAllTechnologies();

    container.setInnerHtml('''
      <div class="app-container">
        <header class="header">
          <h1 class="logo">🧠 Programming Quiz</h1>
          <p class="tagline">Test your programming knowledge with AI-powered quizzes</p>
        </header>
        
        <main class="main-content">
          <section class="hero">
            <h2>Choose a Technology</h2>
            <p>Select a programming language or technology to start your quiz</p>
          </section>
          
          <div class="cards-grid" id="cards-container"></div>
        </main>
        
        <footer class="footer">
          <p>Built with Dart • Farea AL-Dhelaa</p>
        </footer>
      </div>
    ''', validator: _allowAllValidator());

    final cardsContainer = querySelector('#cards-container')!;
    for (final tech in technologies) {
      final card = _createTechCard(tech);
      cardsContainer.append(card);
    }
  }

  Element _createTechCard(Technology tech) {
    final card = DivElement()
      ..classes.add('tech-card')
      ..dataset['tech-id'] = tech.id;

    final difficultyClass = tech.difficulty == Difficulty.beginner
        ? 'difficulty-beginner'
        : tech.difficulty == Difficulty.intermediate
            ? 'difficulty-intermediate'
            : 'difficulty-advanced';

    card.setInnerHtml('''
      <div class="card-icon">${tech.icon}</div>
      <h3 class="card-title">${tech.name}</h3>
      <p class="card-description">${tech.description}</p>
      <span class="difficulty-badge $difficultyClass">${tech.difficulty.displayName}</span>
      <div class="card-footer">
        <span class="question-count">30 Questions</span>
        <button class="start-btn">Start Quiz →</button>
      </div>
    ''', validator: _allowAllValidator());

    card.querySelector('.start-btn')!.onClick.listen((_) {
      _startQuiz(tech);
    });

    card.onClick.listen((event) {
      if (!(event.target as Element).classes.contains('start-btn')) {
        _startQuiz(tech);
      }
    });

    return card;
  }

  void _startQuiz(Technology tech) {
    _currentTechId = tech.id;
    _currentTechName = tech.name;
    _currentQuestionIndex = 0;
    _userAnswers = {};
    _startTime = DateTime.now();

    final allQuestions = _questionBank.getQuestionsForTechnology(tech.id);
    final easyQuestions = allQuestions.where((q) => q.difficulty == QuestionDifficulty.easy).toList()..shuffle(_random);
    final mediumQuestions = allQuestions.where((q) => q.difficulty == QuestionDifficulty.medium).toList()..shuffle(_random);
    final hardQuestions = allQuestions.where((q) => q.difficulty == QuestionDifficulty.hard).toList()..shuffle(_random);

    _currentQuestions = [
      ...easyQuestions.take(10),
      ...mediumQuestions.take(10),
      ...hardQuestions.take(10),
    ]..shuffle(_random);

    _renderQuizPage();
  }

  void _renderQuizPage() {
    if (_currentQuestions.isEmpty) return;

    final container = querySelector('#app')!;
    final question = _currentQuestions[_currentQuestionIndex];
    final progress = ((_currentQuestionIndex + 1) / _currentQuestions.length * 100).toStringAsFixed(0);

    final difficultyClass = question.difficulty == QuestionDifficulty.easy
        ? 'difficulty-beginner'
        : question.difficulty == QuestionDifficulty.medium
            ? 'difficulty-intermediate'
            : 'difficulty-advanced';

    final difficultyText = question.difficulty == QuestionDifficulty.easy
        ? 'Easy'
        : question.difficulty == QuestionDifficulty.medium
            ? 'Medium'
            : 'Hard';

    container.setInnerHtml('''
      <div class="quiz-container">
        <header class="quiz-header">
          <button class="back-btn" id="back-btn">← Back</button>
          <div class="quiz-info">
            <h2>$_currentTechName Quiz</h2>
            <div class="progress-container">
              <div class="progress-bar" style="width: $progress%"></div>
            </div>
            <span class="progress-text">Question ${_currentQuestionIndex + 1} of ${_currentQuestions.length}</span>
          </div>
          <div class="timer-section">
            <label class="timer-toggle">
              <input type="checkbox" id="timer-toggle" ${_timerEnabled ? 'checked' : ''}>
              <span>Timer</span>
            </label>
            <div class="timer ${_timerEnabled ? '' : 'timer-disabled'}" id="timer">
              <span id="timer-value">$_timeRemaining</span>s
            </div>
          </div>
        </header>

        <main class="quiz-main">
          <div class="question-card">
            <div class="question-header">
              <span class="question-number">Q${_currentQuestionIndex + 1}</span>
              <span class="difficulty-badge $difficultyClass">$difficultyText</span>
              ${question.isMultipleChoice ? '<span class="multi-select-badge">Multiple Answers</span>' : ''}
            </div>
            
            <h3 class="question-text">${_escapeHtml(question.questionText)}</h3>
            
            ${question.codeSnippet != null ? '<pre class="code-snippet"><code>${_escapeHtml(question.codeSnippet!)}</code></pre>' : ''}
            
            <div class="options-container" id="options-container"></div>
          </div>
          
          <div class="question-nav" id="question-nav"></div>
        </main>

        <footer class="quiz-footer">
          <button class="nav-btn prev-btn" id="prev-btn" ${_currentQuestionIndex == 0 ? 'disabled' : ''}>← Previous</button>
          <button class="nav-btn next-btn" id="next-btn">
            ${_currentQuestionIndex == _currentQuestions.length - 1 ? 'Finish Quiz' : 'Next →'}
          </button>
        </footer>
      </div>
    ''', validator: _allowAllValidator());

    final optionsContainer = querySelector('#options-container')!;
    for (int i = 0; i < question.options.length; i++) {
      final isSelected = _userAnswers[_currentQuestionIndex]?.contains(i) ?? false;
      final option = _createOptionElement(i, question.options[i], isSelected, question.isMultipleChoice);
      optionsContainer.append(option);
    }

    final questionNav = querySelector('#question-nav')!;
    for (int i = 0; i < _currentQuestions.length; i++) {
      final navBtn = ButtonElement()
        ..classes.add('nav-dot')
        ..text = '${i + 1}';

      if (i == _currentQuestionIndex) {
        navBtn.classes.add('current');
      } else if (_userAnswers.containsKey(i)) {
        navBtn.classes.add('answered');
      }

      navBtn.onClick.listen((_) {
        _currentQuestionIndex = i;
        _resetTimer();
        _renderQuizPage();
      });

      questionNav.append(navBtn);
    }

    querySelector('#back-btn')!.onClick.listen((_) {
      _timer?.cancel();
      _renderHomePage();
    });

    querySelector('#timer-toggle')!.onChange.listen((e) {
      _timerEnabled = (e.target as CheckboxInputElement).checked ?? true;
      if (_timerEnabled) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
      _renderQuizPage();
    });

    querySelector('#prev-btn')!.onClick.listen((_) {
      if (_currentQuestionIndex > 0) {
        _currentQuestionIndex--;
        _resetTimer();
        _renderQuizPage();
      }
    });

    querySelector('#next-btn')!.onClick.listen((_) {
      if (_currentQuestionIndex < _currentQuestions.length - 1) {
        _currentQuestionIndex++;
        _resetTimer();
        _renderQuizPage();
      } else {
        _finishQuiz();
      }
    });

    if (_timerEnabled) {
      _startTimer();
    }
  }

  Element _createOptionElement(int index, String text, bool isSelected, bool isMultiple) {
    final option = DivElement()
      ..classes.add('option')
      ..dataset['index'] = index.toString();

    if (isSelected) {
      option.classes.add('selected');
    }

    option.setInnerHtml('''
      <div class="option-checkbox ${isMultiple ? 'checkbox' : 'radio'} ${isSelected ? 'checked' : ''}"></div>
      <span class="option-label">${String.fromCharCode(65 + index)}.</span>
      <span class="option-text">${_escapeHtml(text)}</span>
    ''', validator: _allowAllValidator());

    option.onClick.listen((_) {
      _selectAnswer(index);
      _renderQuizPage();
    });

    return option;
  }

  void _selectAnswer(int answerIndex) {
    if (!_userAnswers.containsKey(_currentQuestionIndex)) {
      _userAnswers[_currentQuestionIndex] = [];
    }

    final question = _currentQuestions[_currentQuestionIndex];
    if (question.isMultipleChoice) {
      if (_userAnswers[_currentQuestionIndex]!.contains(answerIndex)) {
        _userAnswers[_currentQuestionIndex]!.remove(answerIndex);
      } else {
        _userAnswers[_currentQuestionIndex]!.add(answerIndex);
      }
    } else {
      _userAnswers[_currentQuestionIndex] = [answerIndex];
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timeRemaining--;
      final timerElement = querySelector('#timer-value');
      if (timerElement != null) {
        timerElement.text = '$_timeRemaining';
      }
      if (_timeRemaining <= 0) {
        timer.cancel();
        if (_currentQuestionIndex < _currentQuestions.length - 1) {
          _currentQuestionIndex++;
          _resetTimer();
          _renderQuizPage();
        } else {
          _finishQuiz();
        }
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _timeRemaining = 30;
  }

  void _finishQuiz() {
    _timer?.cancel();
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(_startTime ?? endTime);

    int correctAnswers = 0;
    int easyCorrect = 0;
    int mediumCorrect = 0;
    int hardCorrect = 0;

    List<QuestionResult> questionResults = [];

    for (int i = 0; i < _currentQuestions.length; i++) {
      final question = _currentQuestions[i];
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

    final result = QuizResult(
      technologyId: _currentTechId,
      technologyName: _currentTechName,
      questionResults: questionResults,
      totalQuestions: _currentQuestions.length,
      correctAnswers: correctAnswers,
      easyCorrect: easyCorrect,
      mediumCorrect: mediumCorrect,
      hardCorrect: hardCorrect,
      timeTaken: timeTaken,
      completedAt: endTime,
    );

    _renderResultsPage(result);
  }

  void _renderResultsPage(QuizResult result) {
    final container = querySelector('#app')!;
    final percentage = result.percentage.toStringAsFixed(1);
    final gradeClass = result.grade == 'A+' || result.grade == 'A'
        ? 'grade-excellent'
        : result.grade == 'B'
            ? 'grade-good'
            : result.grade == 'C'
                ? 'grade-average'
                : 'grade-poor';

    container.setInnerHtml('''
      <div class="results-container">
        <header class="results-header">
          <h1>Quiz Complete! 🎉</h1>
          <p>${result.technologyName} Assessment Results</p>
        </header>

        <main class="results-main">
          <div class="score-card">
            <div class="score-circle">
              <div class="score-value">$percentage%</div>
              <div class="score-label">Score</div>
            </div>
            <div class="grade-badge $gradeClass">${result.grade}</div>
          </div>

          <div class="stats-grid">
            <div class="stat-card">
              <div class="stat-icon">✅</div>
              <div class="stat-value">${result.correctAnswers}</div>
              <div class="stat-label">Correct</div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">❌</div>
              <div class="stat-value">${result.totalQuestions - result.correctAnswers}</div>
              <div class="stat-label">Incorrect</div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">⏱️</div>
              <div class="stat-value">${_formatDuration(result.timeTaken)}</div>
              <div class="stat-label">Time</div>
            </div>
          </div>

          <div class="difficulty-breakdown">
            <h3>Performance by Difficulty</h3>
            <div class="breakdown-grid">
              <div class="breakdown-item">
                <span class="difficulty-badge difficulty-beginner">Easy</span>
                <div class="breakdown-bar">
                  <div class="breakdown-fill easy-fill" style="width: ${(result.easyCorrect / 10 * 100).toStringAsFixed(0)}%"></div>
                </div>
                <span class="breakdown-score">${result.easyCorrect}/10</span>
              </div>
              <div class="breakdown-item">
                <span class="difficulty-badge difficulty-intermediate">Medium</span>
                <div class="breakdown-bar">
                  <div class="breakdown-fill medium-fill" style="width: ${(result.mediumCorrect / 10 * 100).toStringAsFixed(0)}%"></div>
                </div>
                <span class="breakdown-score">${result.mediumCorrect}/10</span>
              </div>
              <div class="breakdown-item">
                <span class="difficulty-badge difficulty-advanced">Hard</span>
                <div class="breakdown-bar">
                  <div class="breakdown-fill hard-fill" style="width: ${(result.hardCorrect / 10 * 100).toStringAsFixed(0)}%"></div>
                </div>
                <span class="breakdown-score">${result.hardCorrect}/10</span>
              </div>
            </div>
          </div>

          <div class="ai-analysis" id="ai-analysis">
            <h3>🤖 AI Skill Analysis</h3>
            <div class="analysis-loading" id="analysis-loading">
              <div class="spinner"></div>
              <p>Analyzing your performance...</p>
            </div>
            <div class="analysis-content" id="analysis-content" style="display: none;"></div>
          </div>

          <div class="review-section">
            <h3>📋 Question Review</h3>
            <div class="review-list" id="review-list"></div>
          </div>
        </main>

        <footer class="results-footer">
          <button class="btn btn-primary" id="retry-btn">Try Again</button>
          <button class="btn btn-secondary" id="home-btn">Back to Home</button>
        </footer>
      </div>
    ''', validator: _allowAllValidator());

    final reviewList = querySelector('#review-list')!;
    for (int i = 0; i < result.questionResults.length; i++) {
      final qr = result.questionResults[i];
      final reviewItem = _createReviewItem(i, qr);
      reviewList.append(reviewItem);
    }

    querySelector('#retry-btn')!.onClick.listen((_) {
      final tech = _techDatasource.getTechnologyById(_currentTechId);
      if (tech != null) {
        _startQuiz(tech);
      }
    });

    querySelector('#home-btn')!.onClick.listen((_) {
      _renderHomePage();
    });

    _fetchAIAnalysis(result);
  }

  Element _createReviewItem(int index, QuestionResult qr) {
    final item = DivElement()..classes.add('review-item');
    if (qr.isCorrect) {
      item.classes.add('correct');
    } else {
      item.classes.add('incorrect');
    }

    final userAnswerText = qr.userAnswers.isEmpty
        ? 'Not answered'
        : qr.userAnswers.map((i) => qr.question.options[i]).join(', ');
    final correctAnswerText = qr.question.correctAnswers.map((i) => qr.question.options[i]).join(', ');

    item.setInnerHtml('''
      <div class="review-header">
        <span class="review-number">Q${index + 1}</span>
        <span class="review-status">${qr.isCorrect ? '✅ Correct' : '❌ Incorrect'}</span>
      </div>
      <p class="review-question">${_escapeHtml(qr.question.questionText)}</p>
      <div class="review-answers">
        <p><strong>Your answer:</strong> ${_escapeHtml(userAnswerText)}</p>
        ${!qr.isCorrect ? '<p><strong>Correct answer:</strong> ${_escapeHtml(correctAnswerText)}</p>' : ''}
      </div>
      <p class="review-explanation"><strong>Explanation:</strong> ${_escapeHtml(qr.question.explanation)}</p>
    ''', validator: _allowAllValidator());

    return item;
  }

  Future<void> _fetchAIAnalysis(QuizResult result) async {
    try {
      final response = await http.post(
        Uri.parse('/api/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'technologyName': result.technologyName,
          'totalQuestions': result.totalQuestions,
          'correctAnswers': result.correctAnswers,
          'easyCorrect': result.easyCorrect,
          'mediumCorrect': result.mediumCorrect,
          'hardCorrect': result.hardCorrect,
          'percentage': result.percentage,
          'timeTaken': result.timeTaken.inSeconds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _displayAnalysis(data);
      } else {
        _displayFallbackAnalysis(result);
      }
    } catch (e) {
      _displayFallbackAnalysis(result);
    }
  }

  void _displayAnalysis(Map<String, dynamic> data) {
    final loadingElement = querySelector('#analysis-loading');
    final contentElement = querySelector('#analysis-content');

    if (loadingElement != null) loadingElement.style.display = 'none';
    if (contentElement != null) {
      contentElement.style.display = 'block';
      
      final strengths = (data['strengths'] as List?)?.join('</li><li>') ?? '';
      final weaknesses = (data['weaknesses'] as List?)?.join('</li><li>') ?? '';

      contentElement.setInnerHtml('''
        <div class="skill-level">
          <span class="skill-label">Skill Level:</span>
          <span class="skill-badge">${data['skillLevel'] ?? 'Unknown'}</span>
        </div>
        <p class="analysis-text">${data['analysis'] ?? 'Analysis not available.'}</p>
        ${strengths.isNotEmpty ? '<div class="strengths"><h4>💪 Strengths</h4><ul><li>$strengths</li></ul></div>' : ''}
        ${weaknesses.isNotEmpty ? '<div class="weaknesses"><h4>📈 Areas to Improve</h4><ul><li>$weaknesses</li></ul></div>' : ''}
      ''', validator: _allowAllValidator());
    }
  }

  void _displayFallbackAnalysis(QuizResult result) {
    final percentage = result.percentage;
    String skillLevel;
    List<String> strengths = [];
    List<String> weaknesses = [];

    if (percentage >= 90) {
      skillLevel = 'Expert';
      strengths = ['Excellent understanding of core concepts', 'Strong problem-solving skills'];
    } else if (percentage >= 70) {
      skillLevel = 'Advanced';
      strengths = ['Good grasp of fundamentals', 'Solid practical knowledge'];
      weaknesses = ['Some advanced concepts need review'];
    } else if (percentage >= 50) {
      skillLevel = 'Intermediate';
      strengths = ['Understanding of basic concepts'];
      weaknesses = ['Medium and hard topics need more practice'];
    } else {
      skillLevel = 'Beginner';
      weaknesses = ['Focus on fundamentals', 'Regular practice recommended'];
    }

    if (result.easyCorrect >= 8) strengths.add('Strong foundation in basics');
    if (result.hardCorrect >= 7) strengths.add('Excellent advanced knowledge');
    if (result.easyCorrect < 5) weaknesses.add('Review fundamental concepts');
    if (result.hardCorrect < 3) weaknesses.add('Practice more challenging problems');

    _displayAnalysis({
      'skillLevel': skillLevel,
      'analysis': 'Based on your performance, you scored ${percentage.toStringAsFixed(1)}% overall. You answered ${result.easyCorrect}/10 easy, ${result.mediumCorrect}/10 medium, and ${result.hardCorrect}/10 hard questions correctly.',
      'strengths': strengths,
      'weaknesses': weaknesses,
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  NodeValidator _allowAllValidator() {
    return _TrustedNodeValidator();
  }
}

class _TrustedNodeValidator implements NodeValidator {
  @override
  bool allowsAttribute(Element element, String attributeName, String value) => true;
  @override
  bool allowsElement(Element element) => true;
}

void main() {
  ProgrammingQuizApp().run();
}
