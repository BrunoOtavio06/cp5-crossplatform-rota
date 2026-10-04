import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/date_formatters.dart';
import '../data/models/enums.dart';
import '../data/rota_store.dart';
import '../widgets/add_task_modal.dart';
import '../widgets/custom_button.dart';
import '../widgets/priority_tag.dart';

class DeliveryDetailScreen extends StatelessWidget {
  const DeliveryDetailScreen({super.key, required this.store, required this.deliveryId});

  final RotaStore store;
  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final matches = store.deliveries.where((item) => item.id == deliveryId);
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Entrega')),
            body: const Center(child: Text('Esta entrega não está mais na rota.')),
          );
        }
        final delivery = matches.first;
        final overdue = delivery.isOverdue(store.today);
        return Scaffold(
          appBar: AppBar(title: const Text('Entrega')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
            children: [
              Text(
                delivery.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PriorityTag(priority: delivery.priority),
                  StatusTag(
                    label: overdue ? 'Atrasada' : delivery.status.label,
                    color: overdue
                        ? AppColors.high
                        : delivery.status == DeliveryStatus.concluida
                            ? AppColors.success
                            : AppColors.medium,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _info('Disciplina', delivery.discipline),
              _info('Data limite', DateFormatters.cardDate(delivery.dueDate)),
              _info('Peso', '${delivery.priority.label} · peso ${delivery.priority.weight} no mapa'),
              if (delivery.notes != null && delivery.notes!.isNotEmpty) _info('Notas', delivery.notes!),
              const SizedBox(height: 10),
              Text(
                overdue
                    ? 'Essa entrega já passou do prazo. Conclua ou reavalie a data para limpar o radar.'
                    : delivery.status == DeliveryStatus.concluida
                        ? 'Entrega concluída. Você avançou mais uma etapa da sua rota.'
                        : 'Priorize o ${delivery.title} para manter sua rota em dia.',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: delivery.status == DeliveryStatus.concluida ? 'Reabrir entrega' : 'Marcar como concluída',
                onPressed: () => store.toggleComplete(delivery),
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: 'Editar',
                tone: CustomButtonTone.ghost,
                onPressed: () => AddTaskModal.show(context, store, existing: delivery),
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: 'Remover da rota',
                tone: CustomButtonTone.danger,
                onPressed: () async {
                  await store.removeDelivery(delivery.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text)),
        ],
      ),
    );
  }
}
