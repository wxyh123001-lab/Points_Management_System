import 'package:flutter/material.dart';
import '../models/customer.dart';

class MilestoneBadge extends StatelessWidget {
  final int points;

  const MilestoneBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final level = Customer.milestoneLevel(points);
    if (level == null) return const SizedBox.shrink();

    final (label, color) = switch (level) {
      'gold' => ('金牌', const Color(0xFFF5A623)),
      'silver' => ('银牌', const Color(0xFF4A90D9)),
      _ => ('铜牌', const Color(0xFFB87333)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
