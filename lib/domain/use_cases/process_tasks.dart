import 'package:test_grid_app/core/models/solved_task.dart';
import 'package:test_grid_app/core/repositories/task_repository.dart';
import 'package:test_grid_app/domain/services/shortest_path_finder.dart';

typedef TaskProgressCallback = void Function(int completed, int total);

class ProcessTasksUseCase {
  const ProcessTasksUseCase({
    required TaskRepository repository,
    ShortestPathFinder pathFinder = const ShortestPathFinder(),
  }) : _repository = repository,
       _pathFinder = pathFinder;

  final TaskRepository _repository;
  final ShortestPathFinder _pathFinder;

  Future<List<SolvedTask>> call(
    Uri uri, {
    TaskProgressCallback? onProgress,
  }) async {
    final tasks = await _repository.fetchTasks(uri);
    await _repository.rememberSuccessfulUrl(uri.toString());
    final results = <SolvedTask>[];
    for (var index = 0; index < tasks.length; index++) {
      final task = tasks[index];
      results.add(SolvedTask(task: task, steps: _pathFinder.find(task)));
      onProgress?.call(index + 1, tasks.length);
      await Future<void>.delayed(Duration.zero);
    }
    return List.unmodifiable(results);
  }
}
