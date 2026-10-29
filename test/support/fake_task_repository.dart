import 'dart:async';

import 'package:test_grid_app/core/models/coordinate.dart';
import 'package:test_grid_app/core/models/grid_task.dart';
import 'package:test_grid_app/core/models/solved_task.dart';
import 'package:test_grid_app/core/repositories/task_repository.dart';

class FakeTaskRepository extends TaskRepository {
  FakeTaskRepository({
    List<String> successfulUrls = const [],
    this.failSubmissionCount = 0,
    this.submissionCompleter,
    this.fetchCompleter,
    this.fetchError,
    List<GridTask>? tasks,
  }) : _successfulUrls = List.of(successfulUrls),
       tasks = tasks ?? [_sampleTask];

  static final GridTask _sampleTask = GridTask(
    id: 'task-1',
    field: const ['...', '...', '...'],
    start: const Coordinate(0, 0),
    end: const Coordinate(2, 2),
  );

  final List<GridTask> tasks;
  final List<String> _successfulUrls;
  int failSubmissionCount;
  final Completer<void>? submissionCompleter;
  final Completer<List<GridTask>>? fetchCompleter;
  final Object? fetchError;
  int fetchCount = 0;
  int submitCount = 0;
  Uri? lastUri;
  List<SolvedTask>? lastSubmittedResults;

  @override
  Future<List<GridTask>> fetchTasks(Uri uri) async {
    fetchCount++;
    lastUri = uri;
    if (fetchError != null) throw fetchError!;
    if (fetchCompleter != null) return fetchCompleter!.future;
    return tasks;
  }

  @override
  Future<List<String>> loadSuccessfulUrls() async => List.of(_successfulUrls);

  @override
  Future<void> rememberSuccessfulUrl(String url) async {
    _successfulUrls
      ..remove(url)
      ..insert(0, url);
  }

  @override
  Future<void> submitResults(Uri uri, List<SolvedTask> results) async {
    submitCount++;
    lastUri = uri;
    lastSubmittedResults = results;
    if (submissionCompleter != null) {
      await submissionCompleter!.future;
    }
    if (failSubmissionCount > 0) {
      failSubmissionCount--;
      throw Exception('Could not send results');
    }
  }
}
