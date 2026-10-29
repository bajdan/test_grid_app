import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:test_grid_app/core/models/solved_task.dart';
import 'package:test_grid_app/domain/use_cases/process_tasks.dart';
import 'package:test_grid_app/domain/use_cases/submit_results.dart';

enum ProcessStatus { loading, ready, submitting, submitted, failure }

class ProcessState {
  const ProcessState({
    required this.status,
    this.results = const [],
    this.completed = 0,
    this.total = 0,
    this.error,
  });

  final ProcessStatus status;
  final List<SolvedTask> results;
  final int completed;
  final int total;
  final String? error;

  double? get progress {
    if (status == ProcessStatus.loading && total == 0) return null;
    if (total == 0) return 1;
    return completed / total;
  }

  int get progressPercent => ((progress ?? 0) * 100).round();
}

class ProcessCubit extends Cubit<ProcessState> {
  ProcessCubit({
    required ProcessTasksUseCase processTasks,
    required SubmitResultsUseCase submitResults,
  }) : _processTasks = processTasks,
       _submitResults = submitResults,
       super(const ProcessState(status: ProcessStatus.loading));

  final ProcessTasksUseCase _processTasks;
  final SubmitResultsUseCase _submitResults;
  Uri? _uri;

  Future<void> load(Uri uri) async {
    if (isClosed) return;
    _uri = uri;
    emit(const ProcessState(status: ProcessStatus.loading));
    try {
      final results = await _processTasks(
        uri,
        onProgress: (completed, total) {
          if (isClosed) return;
          emit(
            ProcessState(
              status: ProcessStatus.loading,
              completed: completed,
              total: total,
            ),
          );
        },
      );
      if (isClosed) return;
      emit(
        ProcessState(
          status: ProcessStatus.ready,
          results: results,
          completed: results.length,
          total: results.length,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        ProcessState(
          status: ProcessStatus.failure,
          error: _errorMessage(error),
        ),
      );
    }
  }

  Future<void> sendResults() async {
    final uri = _uri;
    final results = state.results;
    if (isClosed || uri == null || state.status != ProcessStatus.ready) return;

    emit(
      ProcessState(
        status: ProcessStatus.submitting,
        results: results,
        completed: state.completed,
        total: state.total,
      ),
    );
    try {
      await _submitResults(uri, results);
      if (isClosed) return;
      emit(
        ProcessState(
          status: ProcessStatus.submitted,
          results: results,
          completed: state.completed,
          total: state.total,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        ProcessState(
          status: ProcessStatus.ready,
          results: results,
          completed: state.completed,
          total: state.total,
          error: _errorMessage(error),
        ),
      );
    }
  }

  String _errorMessage(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
