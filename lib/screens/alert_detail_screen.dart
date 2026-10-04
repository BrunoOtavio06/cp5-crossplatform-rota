import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/models/models.dart';
import '../data/rota_store.dart';
import '../widgets/custom_button.dart';
import '../widgets/task_card.dart';
import 'delivery_detail_screen.dart';
import 'week_detail_screen.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key, required this.store, required this.alert});

  final RotaStore store;
  final LoadAlert alert;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final week = store.weeks.firstWhere((item) => item.number == alert.week.number);
        return Scaffold(
          appBar: AppBar(title: const Text('Alerta da rota')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
            children: [
              Text(
                alert.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: AppColors.high,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                alert.message,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, height: 1.4, color: AppColors.text),
              ),
              const SizedBox(height: 18),
              const Text(
                'O ROTA soma o peso das entregas da semana. Duas ou mais tarefas de prioridade alta no mesmo recorte viram alerta, para a sobrecarga deixar de ser surpresa.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, height: 1.4, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              const Text(
                'O que está concentrado',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text),
              ),
              const SizedBox(height: 12),
              for (final item in week.pending) ...[
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
              const SizedBox(height: 8),
              CustomButton(
                label: 'Ver a semana completa',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => WeekDetailScreen(store: store, weekNumber: week.number),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
