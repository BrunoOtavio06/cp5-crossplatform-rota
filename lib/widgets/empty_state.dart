import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.route_outlined, color: AppColors.textSecondary, size: 28),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
