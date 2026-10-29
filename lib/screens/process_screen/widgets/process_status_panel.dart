import 'package:flutter/material.dart';

import 'package:test_grid_app/screens/process_screen/process_cubit.dart';

class ProcessStatusPanel extends StatelessWidget {
  const ProcessStatusPanel({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final ProcessState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == ProcessStatus.loading;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                const Icon(Icons.route_rounded, size: 54),
                const SizedBox(height: 20),
                const Text('Loading tasks and calculating paths'),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  key: const ValueKey('process_loader'),
                  value: state.progress,
                ),
                const SizedBox(height: 10),
                Text(
                  state.total == 0
                      ? 'Connecting to server…'
                      : '${state.progressPercent}%',
                ),
              ] else if (state.status == ProcessStatus.failure) ...[
                const Icon(Icons.error_outline, size: 54, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.error ?? 'Could not process tasks.',
                  key: const ValueKey('process_error'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  key: const ValueKey('retry_processing_button'),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ] else ...[
                const Icon(Icons.task_alt_rounded, size: 54),
                const SizedBox(height: 16),
                Text(
                  state.error == null
                      ? 'All calculations are complete.'
                      : 'Results could not be sent.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('${state.progressPercent}%'),
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.error!,
                    key: const ValueKey('process_error'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
