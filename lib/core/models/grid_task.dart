import 'coordinate.dart';

class GridTask {
  GridTask({
    required this.id,
    required List<String> field,
    required this.start,
    required this.end,
  }) : field = List.unmodifiable(field);

  final String id;
  final List<String> field;
  final Coordinate start;
  final Coordinate end;

  int get size => field.length;

  factory GridTask.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final rawField = json['field'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Task id must be a non-empty string.');
    }
    if (rawField is! List || rawField.length < 2 || rawField.length >= 100) {
      throw const FormatException(
        'Task field must be a square grid from 2 to 99 cells.',
      );
    }

    final field = <String>[];
    for (final row in rawField) {
      if (row is! String || row.length != rawField.length) {
        throw const FormatException(
          'Task field must contain equally sized square rows.',
        );
      }
      if (row.split('').any((cell) => cell != '.' && cell != 'X')) {
        throw const FormatException(
          'Task field may contain only "." and "X" cells.',
        );
      }
      field.add(row);
    }

    final start = _parseCoordinate(json['start'], 'start');
    final end = _parseCoordinate(json['end'], 'end');
    if (!_isWithinGrid(start, field.length) ||
        !_isWithinGrid(end, field.length)) {
      throw const FormatException('Task coordinates must be inside the grid.');
    }

    return GridTask(id: id, field: field, start: start, end: end);
  }

  static Coordinate _parseCoordinate(Object? value, String name) {
    if (value is! Map) {
      throw FormatException('Task $name coordinate must be an object.');
    }
    final x = _parseInteger(value['x'], '$name.x');
    final y = _parseInteger(value['y'], '$name.y');
    return Coordinate(x, y);
  }

  static int _parseInteger(Object? value, String name) {
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Task coordinate $name must be an integer.');
  }

  static bool _isWithinGrid(Coordinate point, int size) =>
      point.x >= 0 && point.y >= 0 && point.x < size && point.y < size;
}
