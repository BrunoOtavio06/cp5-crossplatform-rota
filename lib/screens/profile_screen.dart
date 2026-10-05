import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/models/enums.dart';
import '../data/rota_store.dart';
import '../widgets/custom_button.dart';
import 'deliveries_list_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.store});

  final RotaStore store;

  Future<void> _logout(BuildContext context) async {
    final auth = store.auth;
    if (auth == null) {
      Navigator.of(context).pop();
      return;
    }

    await auth.signOut();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(auth: auth),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final student = store.student;
        final pending = store.deliveries
            .where((item) => item.status == DeliveryStatus.pendente)
            .length;
        final done = store.deliveries
            .where((item) => item.status == DeliveryStatus.concluida)
            .length;

        return Scaffold(
          appBar: AppBar(title: const Text('Perfil')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.surface,
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.text,
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                student.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${student.course} · ${student.institution}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              if (store.auth?.email != null)
                Text(
                  store.auth!.email!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                store.source == DataSource.supabase
                    ? 'Dados sincronizados com o Supabase'
                    : 'Dados salvos neste aparelho',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: _stat('Pendentes', '$pending')),
                  const SizedBox(width: 10),
                  Expanded(child: _stat('Concluídas', '$done')),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Olá, ${student.name.split(' ').first}! Veja como está a sua rota nesta semana.',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 22),
              CustomButton(
                label: 'Todas as entregas',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DeliveriesListScreen(store: store),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: 'Resetar dados de demonstração',
                tone: CustomButtonTone.ghost,
                onPressed: () async {
                  await store.resetDemo();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rota restaurada para o semestre mockado.'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: 'Sair da conta',
                tone: CustomButtonTone.danger,
                onPressed: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
