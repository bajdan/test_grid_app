import 'package:flutter/material.dart';

class PreviewLegend extends StatelessWidget {
  const PreviewLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendItem(color: Color(0xFF64FFDA), label: 'Start'),
        _LegendItem(color: Color(0xFF009688), label: 'End'),
        _LegendItem(color: Colors.black, label: 'Blocked'),
        _LegendItem(color: Color(0xFF4CAF50), label: 'Path'),
        _LegendItem(color: Colors.white, label: 'Empty', bordered: true),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.bordered = false,
  });

  final Color color;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: bordered ? Border.all(color: Colors.black26) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}
