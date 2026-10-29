class Coordinate {
  const Coordinate(this.x, this.y);

  final int x;
  final int y;

  Map<String, String> toApiJson() => {'x': '$x', 'y': '$y'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordinate && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x,$y)';
}
