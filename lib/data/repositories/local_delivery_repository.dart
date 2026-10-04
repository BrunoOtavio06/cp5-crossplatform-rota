import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../mock/mock_data.dart';
import '../models/models.dart';
import 'delivery_repository.dart';

class LocalDeliveryRepository implements DeliveryRepository {
  static const _key = 'rota_deliveries_v1';

  @override
  Future<List<Delivery>> fetchAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      final seeded = MockData.deliveries();
      await saveAll(seeded);
      return seeded;
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Delivery.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveAll(List<Delivery> deliveries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(deliveries.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
