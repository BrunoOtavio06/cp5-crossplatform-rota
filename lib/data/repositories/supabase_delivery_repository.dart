import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_config.dart';
import '../../core/auth_service.dart';
import '../models/models.dart';
import 'delivery_repository.dart';

/// Persistência autenticada das entregas no Supabase.
/// A RLS do banco também restringe o acesso ao usuário logado.
class SupabaseDeliveryRepository implements DeliveryRepository {
  SupabaseDeliveryRepository({
    required AuthService auth,
    http.Client? client,
  })  : _auth = auth,
        _client = client ?? http.Client();

  final AuthService _auth;
  final http.Client _client;

  Uri get _table =>
      Uri.parse('${AppConfig.supabaseUrl}/rest/v1/deliveries');

  Map<String, String> get _headers => _auth.authHeaders;

  @override
  Future<List<Delivery>> fetchAll() async {
    await _auth.ensureValidSession();

    final response = await _client.get(
      _table.replace(
        queryParameters: {
          'select': '*',
          'order': 'due_date.asc',
        },
      ),
      headers: _headers,
    );

    if (response.statusCode >= 400) {
      throw Exception(
        'Supabase GET ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Delivery.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveAll(List<Delivery> deliveries) async {
    await _auth.ensureValidSession();

    final userId = _auth.userId;
    if (userId == null) {
      throw StateError('Usuário não autenticado.');
    }

    // As policies do Supabase já limitam a tabela ao usuário logado.
    // O filtro explícito evita depender apenas da implementação do cliente.
    final wipe = await _client.delete(
      _table.replace(
        queryParameters: {
          'user_id': 'eq.$userId',
        },
      ),
      headers: _headers,
    );

    if (wipe.statusCode >= 400) {
      throw Exception(
        'Supabase DELETE ${wipe.statusCode}: ${wipe.body}',
      );
    }

    if (deliveries.isEmpty) return;

    final body = deliveries
        .map(
          (item) => {
            ...item.toJson(),
            'user_id': userId,
          },
        )
        .toList();

    final insert = await _client.post(
      _table,
      headers: {
        ..._headers,
        'Prefer': 'return=minimal',
      },
      body: jsonEncode(body),
    );

    if (insert.statusCode >= 400) {
      throw Exception(
        'Supabase POST ${insert.statusCode}: ${insert.body}',
      );
    }
  }
}
