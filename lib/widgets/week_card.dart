import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/date_formatters.dart';
import '../data/models/models.dart';

class WeekCard extends StatelessWidget {
  const WeekCard({super.key, required this.week, this.onTap});

  final WeekLoad week;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fill = week.pending.isEmpty ? 0.0 : week.fill.clamp(0.18, 0.92);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 136,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.border, width: 1.4),
              ),
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: fill,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: week.level.barColor,
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sem ${week.number}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormatters.weekRange(week.start, week.end),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
