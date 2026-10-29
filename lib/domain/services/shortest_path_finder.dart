import 'dart:collection';

import 'package:test_grid_app/core/models/coordinate.dart';
import 'package:test_grid_app/core/models/grid_task.dart';

class ShortestPathFinder {
  const ShortestPathFinder();

  List<Coordinate> find(GridTask task) {
    final size = task.size;
    if (size < 2 ||
        size >= 100 ||
        task.field.any((row) => row.length != size)) {
      throw const FormatException(
        'Task field must be a square grid from 2 to 99 cells.',
      );
    }
    if (!_isFree(task, task.start) || !_isFree(task, task.end)) {
      throw NoPathException('Start and end cells must be free.');
    }

    final predecessors = <Coordinate, Coordinate?>{task.start: null};
    final queue = Queue<Coordinate>()..add(task.start);
    const directions = [-1, 0, 1];

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == task.end) return _rebuildPath(predecessors, task.end);

      for (final dx in directions) {
        for (final dy in directions) {
          if (dx == 0 && dy == 0) continue;
          final next = Coordinate(current.x + dx, current.y + dy);
          if (predecessors.containsKey(next) || !_isFree(task, next)) continue;
          predecessors[next] = current;
          queue.add(next);
        }
      }
    }

    throw NoPathException('No route from ${task.start} to ${task.end}.');
  }

  bool _isFree(GridTask task, Coordinate point) =>
      point.x >= 0 &&
      point.y >= 0 &&
      point.x < task.size &&
      point.y < task.size &&
      task.field[point.y][point.x] == '.';

  List<Coordinate> _rebuildPath(
    Map<Coordinate, Coordinate?> predecessors,
    Coordinate end,
  ) {
    final path = <Coordinate>[];
    Coordinate? current = end;
    while (current != null) {
      path.add(current);
      current = predecessors[current];
    }
    return path.reversed.toList(growable: false);
  }
}

class NoPathException implements Exception {
  const NoPathException(this.message);

  final String message;

  @override
  String toString() => message;
}
