import 'package:flutter/material.dart';

import '../data/models/enums.dart';

class PriorityTag extends StatelessWidget {
  const PriorityTag({super.key, required this.priority, this.compact = false});

  final TaskPriority priority;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 4 : 5),
      decoration: BoxDecoration(
        color: priority.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11 : 12,
          color: Colors.white,
        ),
      ),
    );
  }
}

class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: color,
        ),
      ),
    );
  }
}
