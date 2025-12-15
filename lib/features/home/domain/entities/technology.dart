import '../../../../core/constants/app_constants.dart';

class Technology {
  final String id;
  final String name;
  final String icon;
  final Difficulty difficulty;
  final String description;
  final int questionCount;

  Technology({
    required this.id,
    required this.name,
    required this.icon,
    required this.difficulty,
    required this.description,
    this.questionCount = 30,
  });
}
