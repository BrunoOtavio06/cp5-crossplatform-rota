import 'package:flutter_test/flutter_test.dart';

import 'package:rota_app/data/load_calculator.dart';
import 'package:rota_app/data/mock/mock_data.dart';
import 'package:rota_app/data/models/enums.dart';
import 'package:rota_app/data/models/models.dart';

void main() {
  test('mapa de carga marca a semana 3 como crítica no semestre mockado', () {
    final weeks = LoadCalculator.weeksFor(MockData.deliveries());
    expect(weeks, hasLength(4));
    expect(weeks[0].level, LoadLevel.leve);
    expect(weeks[1].level, LoadLevel.media);
    expect(weeks[2].level, LoadLevel.critica);
    expect(weeks[3].level, LoadLevel.media);

    final alert = LoadCalculator.criticalAlert(weeks);
    expect(alert, isNotNull);
    expect(alert!.title, 'Semana 3 Crítica!');
    expect(alert.message, contains('Global Solution'));
  });

  test('semana sem pendências fica leve mesmo com histórico concluído', () {
    final weeks = LoadCalculator.weeksFor([
      Delivery(
        id: '1',
        title: 'Checkpoint 1',
        discipline: 'Redes Neurais',
        dueDate: DateTime(2026, 9, 10),
        priority: TaskPriority.alta,
        status: DeliveryStatus.concluida,
      ),
    ]);
    expect(weeks.first.level, LoadLevel.leve);
    expect(weeks.first.fill, 0);
  });
}
