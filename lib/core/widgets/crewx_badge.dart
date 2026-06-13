import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CrewXBadge extends StatelessWidget {
  final String label;
  final Color color;

  const CrewXBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.kBlack,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
