import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../quiz/domain/entities/quiz_result.dart';

enum AnalysisState { initial, loading, completed, error }

class ResultProvider {
  AnalysisState _state = AnalysisState.initial;
  QuizResult? _result;
  String _errorMessage = '';

  AnalysisState get state => _state;
  QuizResult? get result => _result;
  String get errorMessage => _errorMessage;

  void setResult(QuizResult result) {
    _result = result;
    _state = AnalysisState.initial;
  }

  Future<void> analyzeWithAI() async {
    if (_result == null) return;

    _state = AnalysisState.loading;

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'technologyName': _result!.technologyName,
          'totalQuestions': _result!.totalQuestions,
          'correctAnswers': _result!.correctAnswers,
          'easyCorrect': _result!.easyCorrect,
          'mediumCorrect': _result!.mediumCorrect,
          'hardCorrect': _result!.hardCorrect,
          'percentage': _result!.percentage,
          'timeTaken': _result!.timeTaken.inSeconds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _result!.aiAnalysis = data['analysis'];
        _result!.skillLevel = data['skillLevel'];
        _result!.strengths = List<String>.from(data['strengths'] ?? []);
        _result!.weaknesses = List<String>.from(data['weaknesses'] ?? []);
        _state = AnalysisState.completed;
      } else {
        _errorMessage = 'Failed to get AI analysis';
        _state = AnalysisState.error;
        _generateFallbackAnalysis();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AnalysisState.error;
      _generateFallbackAnalysis();
    }
  }

  void _generateFallbackAnalysis() {
    if (_result == null) return;

    final percentage = _result!.percentage;
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

    if (_result!.easyCorrect >= 8) {
      strengths.add('Strong foundation in basics');
    }
    if (_result!.hardCorrect >= 7) {
      strengths.add('Excellent advanced knowledge');
    }
    if (_result!.easyCorrect < 5) {
      weaknesses.add('Review fundamental concepts');
    }
    if (_result!.hardCorrect < 3) {
      weaknesses.add('Practice more challenging problems');
    }

    _result!.skillLevel = skillLevel;
    _result!.strengths = strengths;
    _result!.weaknesses = weaknesses;
    _result!.aiAnalysis = 'Based on your performance, you scored ${percentage.toStringAsFixed(1)}% overall. '
        'You answered ${_result!.easyCorrect}/10 easy, ${_result!.mediumCorrect}/10 medium, and ${_result!.hardCorrect}/10 hard questions correctly.';
  }

  void reset() {
    _state = AnalysisState.initial;
    _result = null;
    _errorMessage = '';
  }
}
