import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/rota_store.dart';
import '../widgets/add_task_modal.dart';
import '../widgets/critical_alert_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import '../widgets/week_card.dart';
import 'alert_detail_screen.dart';
import 'deliveries_list_screen.dart';
import 'delivery_detail_screen.dart';
import 'profile_screen.dart';
import 'week_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.store});

  final RotaStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final upcoming = store.upcoming();
        final lateItems = store.overdue();
        final alert = store.alert;
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                if (store.loading)
                  const Center(child: CircularProgressIndicator(color: AppColors.primary))
                else
                  CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(22, 12, 22, 100),
                        sliver: SliverList.list(
                          children: [
                            _Header(
                              name: store.student.firstName,
                              onProfile: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ProfileScreen(store: store),
                                  ),
                                );
                              },
                            ),
                            if (store.error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                store.error!,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: AppColors.high,
                                ),
                              ),
                            ],
                            if (alert != null) ...[
                              const SizedBox(height: 18),
                              CriticalAlertBanner(
                                alert: alert,
                                onDetails: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => AlertDetailScreen(store: store, alert: alert),
                                    ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 22),
                            const Text(
                              'Carga acumulada',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final week in store.weeks)
                                  Expanded(
                                    child: WeekCard(
                                      week: week,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => WeekDetailScreen(store: store, weekNumber: week.number),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Próximas Entregas',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                                if (lateItems.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => DeliveriesListScreen(
                                            store: store,
                                            initialFilter: DeliveryFilter.atrasadas,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${lateItems.length} atrasadas',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColors.high,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (upcoming.isEmpty)
                              const EmptyState(
                                title: 'Nada no radar',
                                message: 'Você não tem entregas pendentes. Toque no + para criar a próxima rota.',
                              )
                            else
                              for (final item in upcoming) ...[
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
                          ],
                        ),
                      ),
                    ],
                  ),
                Positioned(
                  right: 20,
                  bottom: 24,
                  child: GestureDetector(
                    onTap: () => AddTaskModal.show(context, store),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x662864E8), blurRadius: 18, offset: Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.add, color: AppColors.text, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.onProfile});

  final String name;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Olá, $name',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 34,
              height: 1.1,
              color: AppColors.text,
            ),
          ),
        ),
        InkWell(
          onTap: onProfile,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
