import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:test_grid_app/core/repositories/task_repository.dart';
import 'package:test_grid_app/domain/use_cases/process_tasks.dart';
import 'package:test_grid_app/domain/use_cases/submit_results.dart';
import 'package:test_grid_app/screens/process_screen/process_cubit.dart';
import 'package:test_grid_app/screens/process_screen/widgets/process_status_panel.dart';
import 'package:test_grid_app/screens/result_list_screen/result_list_screen.dart';
import 'package:test_grid_app/widgets/bottom_action_button.dart';

class ProcessScreen extends StatelessWidget {
  const ProcessScreen({super.key, required this.uri, required this.repository});

  final Uri uri;
  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProcessCubit(
        processTasks: ProcessTasksUseCase(repository: repository),
        submitResults: SubmitResultsUseCase(repository),
      )..load(uri),
      child: BlocConsumer<ProcessCubit, ProcessState>(
        listener: (context, state) {
          if (state.status == ProcessStatus.submitted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ResultListScreen(results: state.results),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProcessCubit>();
          final canSendResults =
              state.status == ProcessStatus.ready ||
              state.status == ProcessStatus.submitting;
          final isSubmitting = state.status == ProcessStatus.submitting;
          return Scaffold(
            appBar: AppBar(title: const Text('Process screen')),
            bottomNavigationBar: canSendResults
                ? BottomActionButton(
                    buttonKey: const ValueKey('send_results_button'),
                    onPressed: isSubmitting ? null : cubit.sendResults,
                    child: isSubmitting
                        ? const SizedBox(
                            key: ValueKey('submit_loader'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send results to server'),
                  )
                : null,
            body: ProcessStatusPanel(
              state: state,
              onRetry: () => cubit.load(uri),
            ),
          );
        },
      ),
    );
  }
}
