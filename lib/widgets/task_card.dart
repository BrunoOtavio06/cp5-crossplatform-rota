import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/date_formatters.dart';
import '../data/models/enums.dart';
import '../data/models/models.dart';
import 'priority_tag.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.delivery, this.today, this.onTap});

  final Delivery delivery;
  final DateTime? today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final overdue = today != null && delivery.isOverdue(today!);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: overdue ? AppColors.high.withValues(alpha: 0.55) : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.text,
                        decoration: delivery.status == DeliveryStatus.concluida
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormatters.cardDate(delivery.dueDate)}  |  ${delivery.discipline}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PriorityTag(priority: delivery.priority),
            ],
          ),
        ),
      ),
    );
  }
}
