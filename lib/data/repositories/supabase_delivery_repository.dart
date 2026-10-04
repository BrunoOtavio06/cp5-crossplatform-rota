import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_config.dart';
import '../models/models.dart';
import 'delivery_repository.dart';

/// Cliente REST do Supabase (PostgREST). Sem SDK pesado: o protótipo
/// só precisa ler e gravar a tabela `deliveries`.
class SupabaseDeliveryRepository implements DeliveryRepository {
  SupabaseDeliveryRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri get _table => Uri.parse('${AppConfig.supabaseUrl}/rest/v1/deliveries');

  // A chave publicável (sb_publishable_...) não é um JWT. O Supabase pede que
  // ela vá só no header `apikey`, nunca em `Authorization: Bearer`.
  Map<String, String> get _headers => {
        'apikey': AppConfig.supabasePublishableKey,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  @override
  Future<List<Delivery>> fetchAll() async {
    final response = await _client.get(
      _table.replace(queryParameters: {'select': '*', 'order': 'due_date.asc'}),
      headers: _headers,
    );
    if (response.statusCode >= 400) {
      throw Exception('Supabase GET ${response.statusCode}: ${response.body}');
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Delivery.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveAll(List<Delivery> deliveries) async {
    final wipe = await _client.delete(
      _table.replace(queryParameters: {'id': 'not.is.null'}),
      headers: _headers,
    );
    if (wipe.statusCode >= 400) {
      throw Exception('Supabase DELETE ${wipe.statusCode}: ${wipe.body}');
    }
    if (deliveries.isEmpty) return;
    final insert = await _client.post(
      _table,
      headers: _headers,
      body: jsonEncode(deliveries.map((item) => item.toJson()).toList()),
    );
    if (insert.statusCode >= 400) {
      throw Exception('Supabase POST ${insert.statusCode}: ${insert.body}');
    }
  }
}
