import 'coordinate.dart';
import 'grid_task.dart';

class SolvedTask {
  SolvedTask({required this.task, required List<Coordinate> steps})
    : steps = List.unmodifiable(steps);

  final GridTask task;
  final List<Coordinate> steps;

  String get path => steps.map((step) => step.toString()).join('->');

  Map<String, Object> toApiJson() => {
    'id': task.id,
    'result': {
      'steps': steps.map((step) => step.toApiJson()).toList(),
      'path': path,
    },
  };
}
