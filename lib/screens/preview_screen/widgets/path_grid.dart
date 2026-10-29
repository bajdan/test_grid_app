import 'package:flutter/material.dart';

import 'package:test_grid_app/core/models/coordinate.dart';
import 'package:test_grid_app/core/models/solved_task.dart';

class PathGrid extends StatelessWidget {
  const PathGrid({super.key, required this.result});

  final SolvedTask result;

  static const double _cellExtent = 60;

  @override
  Widget build(BuildContext context) {
    final task = result.task;
    final gridExtent = task.size * _cellExtent;
    final routeCoordinates = result.steps.toSet();
    return Center(
      child: InteractiveViewer(
        minScale: 0.35,
        maxScale: 3,
        boundaryMargin: const EdgeInsets.all(48),
        child: SizedBox(
          width: gridExtent,
          height: gridExtent,
          child: Container(
            color: Colors.black,
            child: GridView.builder(
              padding: const EdgeInsets.all(1),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: task.size,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: task.size * task.size,
              itemBuilder: (context, index) {
                final x = index % task.size;
                final y = index ~/ task.size;
                final coordinate = Coordinate(x, y);
                final color = _cellColor(coordinate, routeCoordinates);
                return Container(
                  key: ValueKey('grid_cell_${x}_$y'),
                  alignment: Alignment.center,
                  color: color,
                  child: Text(
                    coordinate.toString(),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: task.size > 12 ? 9 : 11,
                      color: color == Colors.black
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _cellColor(Coordinate coordinate, Set<Coordinate> routeCoordinates) {
    if (coordinate == result.task.start) {
      return const Color(0xFF64FFDA);
    }
    if (coordinate == result.task.end) {
      return const Color(0xFF009688);
    }
    if (result.task.field[coordinate.y][coordinate.x] == 'X') {
      return Colors.black;
    }
    if (routeCoordinates.contains(coordinate)) {
      return const Color(0xFF4CAF50);
    }
    return Colors.white;
  }
}
