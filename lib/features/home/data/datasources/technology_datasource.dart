import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/technology.dart';

class TechnologyDatasource {
  static final List<Technology> technologies = [
    Technology(
      id: 'dart',
      name: 'Dart',
      icon: '🎯',
      difficulty: Difficulty.intermediate,
      description: 'Modern language for building apps',
    ),
    Technology(
      id: 'flutter',
      name: 'Flutter',
      icon: '💙',
      difficulty: Difficulty.intermediate,
      description: 'Cross-platform UI framework',
    ),
    Technology(
      id: 'java',
      name: 'Java',
      icon: '☕',
      difficulty: Difficulty.intermediate,
      description: 'Enterprise programming language',
    ),
    Technology(
      id: 'python',
      name: 'Python',
      icon: '🐍',
      difficulty: Difficulty.beginner,
      description: 'Versatile scripting language',
    ),
    Technology(
      id: 'javascript',
      name: 'JavaScript',
      icon: '⚡',
      difficulty: Difficulty.beginner,
      description: 'Web programming language',
    ),
    Technology(
      id: 'typescript',
      name: 'TypeScript',
      icon: '📘',
      difficulty: Difficulty.intermediate,
      description: 'Typed JavaScript superset',
    ),
    Technology(
      id: 'laravel',
      name: 'Laravel',
      icon: '🔴',
      difficulty: Difficulty.intermediate,
      description: 'PHP web framework',
    ),
    Technology(
      id: 'react',
      name: 'React',
      icon: '⚛️',
      difficulty: Difficulty.intermediate,
      description: 'JavaScript UI library',
    ),
    Technology(
      id: 'vue',
      name: 'Vue.js',
      icon: '💚',
      difficulty: Difficulty.beginner,
      description: 'Progressive JS framework',
    ),
    Technology(
      id: 'angular',
      name: 'Angular',
      icon: '🅰️',
      difficulty: Difficulty.advanced,
      description: 'Full-featured web framework',
    ),
    Technology(
      id: 'sql',
      name: 'SQL',
      icon: '🗄️',
      difficulty: Difficulty.beginner,
      description: 'Database query language',
    ),
    Technology(
      id: 'git',
      name: 'Git',
      icon: '📦',
      difficulty: Difficulty.beginner,
      description: 'Version control system',
    ),
    Technology(
      id: 'oop',
      name: 'OOP',
      icon: '🧱',
      difficulty: Difficulty.intermediate,
      description: 'Object-Oriented Programming',
    ),
    Technology(
      id: 'algorithms',
      name: 'Algorithms',
      icon: '🧮',
      difficulty: Difficulty.advanced,
      description: 'Data structures & algorithms',
    ),
    Technology(
      id: 'nodejs',
      name: 'Node.js',
      icon: '🟢',
      difficulty: Difficulty.intermediate,
      description: 'JavaScript runtime',
    ),
    Technology(
      id: 'rust',
      name: 'Rust',
      icon: '🦀',
      difficulty: Difficulty.advanced,
      description: 'Systems programming language',
    ),
    Technology(
      id: 'go',
      name: 'Go',
      icon: '🐹',
      difficulty: Difficulty.intermediate,
      description: 'Cloud-native language',
    ),
    Technology(
      id: 'kotlin',
      name: 'Kotlin',
      icon: '🟣',
      difficulty: Difficulty.intermediate,
      description: 'Modern JVM language',
    ),
    Technology(
      id: 'swift',
      name: 'Swift',
      icon: '🍎',
      difficulty: Difficulty.intermediate,
      description: 'Apple development language',
    ),
    Technology(
      id: 'csharp',
      name: 'C#',
      icon: '💜',
      difficulty: Difficulty.intermediate,
      description: '.NET programming language',
    ),
  ];

  List<Technology> getAllTechnologies() {
    return technologies;
  }

  Technology? getTechnologyById(String id) {
    try {
      return technologies.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
