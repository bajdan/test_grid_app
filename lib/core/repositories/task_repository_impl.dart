import 'package:test_grid_app/core/api/task_api_client.dart';
import 'package:test_grid_app/core/models/grid_task.dart';
import 'package:test_grid_app/core/models/solved_task.dart';
import 'package:test_grid_app/core/repositories/task_repository.dart';
import 'package:test_grid_app/core/storage/url_history_store.dart';

class TaskRepositoryImpl extends TaskRepository {
  const TaskRepositoryImpl({
    required this.apiClient,
    required this.historyStore,
  });

  final TaskApiClient apiClient;
  final UrlHistoryStore historyStore;

  @override
  Future<List<GridTask>> fetchTasks(Uri uri) async {
    final response = await apiClient.getJson(uri);
    final hasError = response['error'];
    if (hasError is! bool) {
      throw const FormatException(
        'The server response is missing the error flag.',
      );
    }
    if (hasError) {
      final message = response['message'];
      throw ApiException(
        message is String && message.isNotEmpty
            ? message
            : 'The server returned an error.',
      );
    }

    final data = response['data'];
    if (data is! List) {
      throw const FormatException(
        'The server response is missing the task list.',
      );
    }
    return data
        .map((item) {
          if (item is! Map) {
            throw const FormatException('A task in the response is invalid.');
          }
          return GridTask.fromJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }

  @override
  Future<void> submitResults(Uri uri, List<SolvedTask> results) => apiClient
      .postJson(uri, results.map((result) => result.toApiJson()).toList());

  @override
  Future<List<String>> loadSuccessfulUrls() => historyStore.load();

  @override
  Future<void> rememberSuccessfulUrl(String url) =>
      historyStore.saveSuccessful(url);
}
