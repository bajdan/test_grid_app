import 'package:test_grid_app/core/models/solved_task.dart';
import 'package:test_grid_app/core/repositories/task_repository.dart';

class SubmitResultsUseCase {
  const SubmitResultsUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(Uri uri, List<SolvedTask> results) =>
      _repository.submitResults(uri, results);
}
