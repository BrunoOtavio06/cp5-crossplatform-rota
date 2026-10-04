import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/date_formatters.dart';
import '../data/models/enums.dart';
import '../data/rota_store.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/priority_tag.dart';
import '../widgets/task_card.dart';
import 'delivery_detail_screen.dart';

class WeekDetailScreen extends StatelessWidget {
  const WeekDetailScreen({super.key, required this.store, required this.weekNumber});

  final RotaStore store;
  final int weekNumber;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final week = store.weeks.firstWhere((item) => item.number == weekNumber);
        final tip = switch (week.level) {
          LoadLevel.leve => 'Semana leve. Bom momento para adiantar o que vem pela frente.',
          LoadLevel.media => 'Carga equilibrada. Mantenha o ritmo e não deixe acumular.',
          LoadLevel.alta => 'A semana está pesada. Priorize as entregas de peso alto.',
          LoadLevel.critica => 'Semana crítica. Reavalie prazos agora, enquanto ainda dá tempo de agir.',
        };
        return Scaffold(
          appBar: AppBar(
            title: Text('Semana ${week.number}'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatters.weekRange(week.start, week.end),
                      style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusTag(label: 'Carga ${week.level.label}', color: week.level.barColor),
                        const SizedBox(width: 8),
                        StatusTag(label: '${week.pending.length} pendentes', color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(tip, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.text, height: 1.35)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Entregas desta semana',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text),
              ),
              const SizedBox(height: 12),
              if (week.deliveries.isEmpty)
                const EmptyState(
                  title: 'Nenhuma entrega',
                  message: 'Esta semana está vazia no mapa. Use o botão abaixo se quiser puxar uma tarefa para cá.',
                )
              else
                for (final item in week.deliveries) ...[
                  TaskCard(
                    delivery: item,
                    today: store.today,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DeliveryDetailScreen(store: store, deliveryId: item.id),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 12),
              CustomButton(
                label: 'Voltar ao mapa',
                onPressed: () => Navigator.of(context).pop(),
                tone: CustomButtonTone.ghost,
              ),
            ],
          ),
        );
      },
    );
  }
}
