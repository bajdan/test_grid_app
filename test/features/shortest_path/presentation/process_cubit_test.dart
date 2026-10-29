import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_grid_app/core/models/coordinate.dart';
import 'package:test_grid_app/core/models/grid_task.dart';
import 'package:test_grid_app/domain/use_cases/process_tasks.dart';
import 'package:test_grid_app/domain/use_cases/submit_results.dart';
import 'package:test_grid_app/screens/process_screen/process_cubit.dart';
import '../../../support/fake_task_repository.dart';

void main() {
  test('emits per-task progress while calculating a batch', () async {
    final repository = FakeTaskRepository(
      tasks: [
        GridTask(
          id: 'one',
          field: const ['..', '..'],
          start: const Coordinate(0, 0),
          end: const Coordinate(1, 1),
        ),
        GridTask(
          id: 'two',
          field: const ['..', '..'],
          start: const Coordinate(1, 0),
          end: const Coordinate(0, 1),
        ),
      ],
    );
    final cubit = ProcessCubit(
      processTasks: ProcessTasksUseCase(repository: repository),
      submitResults: SubmitResultsUseCase(repository),
    );
    final progress = <int>[];
    final subscription = cubit.stream.listen((state) {
      if (state.status == ProcessStatus.loading && state.total > 0) {
        progress.add(state.progressPercent);
      }
    });

    await cubit.load(Uri.parse('https://example.com/api'));
    await Future<void>.delayed(Duration.zero);

    expect(progress, [50, 100]);
    expect(cubit.state.status, ProcessStatus.ready);
    await subscription.cancel();
    await cubit.close();
  });

  test(
    'does not emit after the process screen closes during a request',
    () async {
      final fetch = Completer<List<GridTask>>();
      final repository = FakeTaskRepository(fetchCompleter: fetch);
      final cubit = ProcessCubit(
        processTasks: ProcessTasksUseCase(repository: repository),
        submitResults: SubmitResultsUseCase(repository),
      );
      final loading = cubit.load(Uri.parse('https://example.com/api'));
      await Future<void>.delayed(Duration.zero);

      await cubit.close();
      fetch.complete([
        GridTask(
          id: 'task',
          field: const ['..', '..'],
          start: const Coordinate(0, 0),
          end: const Coordinate(1, 1),
        ),
      ]);

      await expectLater(loading, completes);
    },
  );
}
