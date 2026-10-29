import '../models/grid_task.dart';
import '../models/solved_task.dart';

abstract class TaskRepository {
  const TaskRepository();

  Future<List<GridTask>> fetchTasks(Uri uri);

  Future<void> submitResults(Uri uri, List<SolvedTask> results);

  Future<List<String>> loadSuccessfulUrls();

  Future<void> rememberSuccessfulUrl(String url);
}
