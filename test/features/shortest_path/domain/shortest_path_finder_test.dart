import 'package:flutter_test/flutter_test.dart';
import 'package:test_grid_app/core/models/coordinate.dart';
import 'package:test_grid_app/core/models/grid_task.dart';
import 'package:test_grid_app/domain/services/shortest_path_finder.dart';

void main() {
  group('ShortestPathFinder', () {
    const finder = ShortestPathFinder();

    test('returns a minimal eight-direction path including both endpoints', () {
      final task = GridTask(
        id: 'diagonal',
        field: const ['...', '...', '...'],
        start: const Coordinate(0, 0),
        end: const Coordinate(2, 2),
      );

      final path = finder.find(task);

      expect(path.first, task.start);
      expect(path.last, task.end);
      expect(path, hasLength(3));
    });

    test(
      'allows a diagonal between blocked side cells when its destination is free',
      () {
        final task = GridTask(
          id: 'corner',
          field: const ['.X', 'X.'],
          start: const Coordinate(0, 0),
          end: const Coordinate(1, 1),
        );

        expect(finder.find(task), const [Coordinate(0, 0), Coordinate(1, 1)]);
      },
    );

    test('routes around a blocked cell using the minimum number of moves', () {
      final task = GridTask(
        id: 'obstacle',
        field: const ['.X.', '...', '...'],
        start: const Coordinate(0, 0),
        end: const Coordinate(2, 0),
      );

      final path = finder.find(task);

      expect(path, hasLength(3));
      expect(path.first, task.start);
      expect(path.last, task.end);
      expect(path.any((point) => point == const Coordinate(1, 0)), isFalse);
      for (var index = 1; index < path.length; index++) {
        final dx = (path[index].x - path[index - 1].x).abs();
        final dy = (path[index].y - path[index - 1].y).abs();
        expect(dx <= 1 && dy <= 1 && (dx != 0 || dy != 0), isTrue);
      }
    });

    test('returns one coordinate when start equals end', () {
      final task = GridTask(
        id: 'same',
        field: const ['..', '..'],
        start: const Coordinate(1, 1),
        end: const Coordinate(1, 1),
      );

      expect(finder.find(task), const [Coordinate(1, 1)]);
    });

    test('throws when the start or destination is blocked or unreachable', () {
      final blockedTarget = GridTask(
        id: 'blocked',
        field: const ['.X', '..'],
        start: const Coordinate(0, 0),
        end: const Coordinate(1, 0),
      );
      final unreachable = GridTask(
        id: 'unreachable',
        field: const ['.X.', 'XXX', '...'],
        start: const Coordinate(0, 0),
        end: const Coordinate(2, 2),
      );

      expect(() => finder.find(blockedTarget), throwsA(isA<NoPathException>()));
      expect(() => finder.find(unreachable), throwsA(isA<NoPathException>()));
    });
  });
}
