import '../../data/datasources/technology_datasource.dart';
import '../../domain/entities/technology.dart';

class HomeProvider {
  final TechnologyDatasource _datasource = TechnologyDatasource();

  List<Technology> get technologies => _datasource.getAllTechnologies();

  Technology? getTechnologyById(String id) {
    return _datasource.getTechnologyById(id);
  }
}
