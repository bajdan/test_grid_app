import 'package:flutter/material.dart';

import 'package:test_grid_app/core/models/solved_task.dart';
import 'package:test_grid_app/widgets/route_path_text.dart';

class TaskResultTile extends StatelessWidget {
  const TaskResultTile({super.key, required this.result, required this.onTap});

  final SolvedTask result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: ValueKey('result_${result.task.id}'),
        title: RoutePathText(
          path: result.path,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
