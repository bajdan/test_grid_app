import 'package:flutter/material.dart';

import 'package:test_grid_app/core/models/solved_task.dart';
import 'package:test_grid_app/screens/preview_screen/widgets/path_grid.dart';
import 'package:test_grid_app/screens/preview_screen/widgets/preview_legend.dart';
import 'package:test_grid_app/widgets/route_path_text.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.result});

  final SolvedTask result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview screen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RoutePathText(
                    key: const ValueKey('preview_path'),
                    path: result.path,
                    maxLines: 1,
                    softWrap: false,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const PreviewLegend(),
            const SizedBox(height: 16),
            Expanded(child: PathGrid(result: result)),
          ],
        ),
      ),
    );
  }
}
