import 'models/enums.dart';
import 'models/models.dart';

class LoadCalculator {
  static final sprintStarts = [
    DateTime(2026, 9, 8),
    DateTime(2026, 9, 15),
    DateTime(2026, 9, 22),
    DateTime(2026, 9, 29),
  ];

  /// Três entregas de peso alto no mesmo recorte = barra cheia.
  static const maxScore = 9.0;

  static List<WeekLoad> weeksFor(List<Delivery> deliveries) {
    return List.generate(sprintStarts.length, (index) {
      final start = sprintStarts[index];
      final end = start.add(const Duration(days: 6));
      final inWeek = deliveries.where((item) => _inRange(item.dueDate, start, end)).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      final pending = inWeek.where((item) => item.status == DeliveryStatus.pendente);
      final score = pending.fold<int>(0, (sum, item) => sum + item.priority.weight);
      final fill = (score / maxScore).clamp(0.0, 1.0);
      final altaCount = pending.where((item) => item.priority == TaskPriority.alta).length;
      return WeekLoad(
        number: index + 1,
        start: start,
        end: end,
        deliveries: inWeek,
        score: score,
        fill: fill,
        level: levelFor(fill: fill, altaCount: altaCount, pendingCount: pending.length),
      );
    });
  }

  static LoadLevel levelFor({
    required double fill,
    required int altaCount,
    required int pendingCount,
  }) {
    if (pendingCount == 0) return LoadLevel.leve;
    if (altaCount >= 2 || fill >= 0.8) return LoadLevel.critica;
    if (fill >= 0.55) return LoadLevel.alta;
    if (fill >= 0.28) return LoadLevel.media;
    return LoadLevel.leve;
  }

  static LoadAlert? criticalAlert(List<WeekLoad> weeks) {
    final critical = weeks.where((week) => week.level == LoadLevel.critica).toList();
    if (critical.isEmpty) return null;
    final week = critical.first;
    final alta = week.pending.where((item) => item.priority == TaskPriority.alta).toList();
    final checkpoints = alta.where((item) => item.title.toLowerCase().contains('checkpoint')).length;
    final hasGlobal = alta.any((item) => item.title.toLowerCase().contains('global'));
    final message = _message(week: week, checkpoints: checkpoints, hasGlobal: hasGlobal);
    return LoadAlert(
      week: week,
      title: 'Semana ${week.number} Crítica!',
      message: message,
    );
  }

  static String _message({
    required WeekLoad week,
    required int checkpoints,
    required bool hasGlobal,
  }) {
    if (checkpoints >= 2 && hasGlobal) {
      return 'Você tem 2 Checkpoints e a entrega da Global Solution acumulados nos mesmos dias. Reavalie seus prazos.';
    }
    if (week.pending.length >= 3) {
      return 'Você tem ${week.pending.length} entregas acumuladas na mesma semana. Reavalie seus prazos.';
    }
    return 'A carga desta semana está pesada. Priorize o que tem maior peso para manter a rota em dia.';
  }

  static bool _inRange(DateTime date, DateTime start, DateTime end) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }
}
