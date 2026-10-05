import 'package:flutter/foundation.dart';

import '../core/app_config.dart';
import '../core/auth_service.dart';
import 'load_calculator.dart';
import 'mock/mock_data.dart';
import 'models/enums.dart';
import 'models/models.dart';
import 'repositories/delivery_repository.dart';
import 'repositories/local_delivery_repository.dart';
import 'repositories/supabase_delivery_repository.dart';

enum DataSource { local, supabase }

class RotaStore extends ChangeNotifier {
  RotaStore({
    LocalDeliveryRepository? local,
    DeliveryRepository? remote,
    AuthService? auth,
    DateTime Function()? clock,
  })  : _local = local ?? LocalDeliveryRepository(),
        _auth = auth,
        _remote = remote ??
            ((AppConfig.hasSupabase && auth != null)
                ? SupabaseDeliveryRepository(auth: auth)
                : null),
        _clock = clock ?? (() => AppConfig.demoToday);

  final LocalDeliveryRepository _local;
  final DeliveryRepository? _remote;
  final AuthService? _auth;
  final DateTime Function() _clock;

  bool loading = true;
  String? error;
  DataSource source = DataSource.local;
  List<Delivery> deliveries = const [];

  AuthService? get auth => _auth;

  Student get student {
    final email = _auth?.email;
    if (email == null || email.isEmpty) return MockData.student;

    final name = email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    final words = name
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .toList();

    return Student(
      name: words.isEmpty ? MockData.student.name : words.join(' '),
      course: MockData.student.course,
      rm: MockData.student.rm,
      institution: MockData.student.institution,
    );
  }

  DateTime get today => _clock();

  List<WeekLoad> get weeks => LoadCalculator.weeksFor(deliveries);
  LoadAlert? get alert => LoadCalculator.criticalAlert(weeks);

  List<Delivery> overdue() {
    return deliveries.where((item) => item.isOverdue(today)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<Delivery> upcoming({int limit = 6}) {
    final future = deliveries
        .where(
          (item) =>
              item.status == DeliveryStatus.pendente &&
              !item.isOverdue(today),
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (future.length <= limit) return future;
    return future.take(limit).toList();
  }

  Future<void> bootstrap() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      if (_remote != null && _auth?.isAuthenticated == true) {
        var remoteItems = await _remote.fetchAll();

        // Cada conta recebe sua própria cópia inicial de demonstração.
        if (remoteItems.isEmpty) {
          remoteItems = MockData.deliveries();
          await _remote.saveAll(remoteItems);
        }

        deliveries = remoteItems;
        source = DataSource.supabase;
        await _local.saveAll(remoteItems);
      } else {
        deliveries = await _local.fetchAll();
        source = DataSource.local;
      }
    } catch (err) {
      deliveries = await _local.fetchAll();
      source = DataSource.local;
      error = 'Não foi possível falar com o Supabase. Usando dados locais.';
      debugPrint('ROTA fallback: $err');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addDelivery(Delivery delivery) async {
    deliveries = [...deliveries, delivery];
    await _persist();
  }

  Future<void> updateDelivery(Delivery delivery) async {
    deliveries = [
      for (final item in deliveries)
        if (item.id == delivery.id) delivery else item,
    ];
    await _persist();
  }

  Future<void> removeDelivery(String id) async {
    deliveries = deliveries.where((item) => item.id != id).toList();
    await _persist();
  }

  Future<void> toggleComplete(Delivery delivery) async {
    final next = delivery.status == DeliveryStatus.concluida
        ? DeliveryStatus.pendente
        : DeliveryStatus.concluida;
    await updateDelivery(delivery.copyWith(status: next));
  }

  Future<void> resetDemo() async {
    await _local.reset();
    deliveries = MockData.deliveries();
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    await _local.saveAll(deliveries);

    if (_remote != null && source == DataSource.supabase) {
      try {
        await _remote.saveAll(deliveries);
      } catch (err) {
        error =
            'A edição ficou salva neste aparelho, mas não no Supabase.';
        debugPrint('ROTA persist remote: $err');
        notifyListeners();
      }
    }
  }
}
