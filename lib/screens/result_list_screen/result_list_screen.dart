import 'package:flutter/material.dart';

import 'package:test_grid_app/core/models/solved_task.dart';
import 'package:test_grid_app/screens/preview_screen/preview_screen.dart';
import 'package:test_grid_app/screens/result_list_screen/widgets/task_result_tile.dart';

class ResultListScreen extends StatelessWidget {
  const ResultListScreen({super.key, required this.results});

  final List<SolvedTask> results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result list screen')),
      body: results.isEmpty
          ? const Center(child: Text('No tasks found.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final result = results[index];
                return TaskResultTile(
                  result: result,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PreviewScreen(result: result),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
