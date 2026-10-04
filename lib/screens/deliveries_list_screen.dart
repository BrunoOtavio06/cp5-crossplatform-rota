import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/models/enums.dart';
import '../data/models/models.dart';
import '../data/rota_store.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'delivery_detail_screen.dart';

enum DeliveryFilter { todas, pendentes, concluidas, atrasadas }

class DeliveriesListScreen extends StatefulWidget {
  const DeliveriesListScreen({super.key, required this.store, this.initialFilter = DeliveryFilter.todas});

  final RotaStore store;
  final DeliveryFilter initialFilter;

  @override
  State<DeliveriesListScreen> createState() => _DeliveriesListScreenState();
}

class _DeliveriesListScreenState extends State<DeliveriesListScreen> {
  late DeliveryFilter _filter = widget.initialFilter;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final items = _apply(widget.store.deliveries)
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        return Scaffold(
          appBar: AppBar(title: const Text('Todas as entregas')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final filter in DeliveryFilter.values)
                    ChoiceChip(
                      label: Text(_label(filter)),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: _filter == filter ? AppColors.text : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const EmptyState(
                  title: 'Nenhum item neste filtro',
                  message: 'Troque o filtro ou cadastre uma nova entrega no mapa.',
                )
              else
                for (final item in items) ...[
                  TaskCard(
                    delivery: item,
                    today: widget.store.today,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DeliveryDetailScreen(
                            store: widget.store,
                            deliveryId: item.id,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        );
      },
    );
  }

  List<Delivery> _apply(List<Delivery> source) {
    final today = widget.store.today;
    return source.where((item) {
      return switch (_filter) {
        DeliveryFilter.todas => true,
        DeliveryFilter.pendentes => item.status == DeliveryStatus.pendente,
        DeliveryFilter.concluidas => item.status == DeliveryStatus.concluida,
        DeliveryFilter.atrasadas => item.isOverdue(today),
      };
    }).toList();
  }

  String _label(DeliveryFilter filter) => switch (filter) {
        DeliveryFilter.todas => 'Todas',
        DeliveryFilter.pendentes => 'Pendentes',
        DeliveryFilter.concluidas => 'Concluídas',
        DeliveryFilter.atrasadas => 'Atrasadas',
      };
}
