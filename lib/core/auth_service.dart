import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_config.dart';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final DateTime expiresAt;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService extends ChangeNotifier {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static const _accessTokenKey = 'rota_auth_access_token';
  static const _refreshTokenKey = 'rota_auth_refresh_token';
  static const _userIdKey = 'rota_auth_user_id';
  static const _emailKey = 'rota_auth_email';
  static const _expiresAtKey = 'rota_auth_expires_at';

  final http.Client _client;
  AuthSession? _session;

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;
  String? get userId => _session?.userId;
  String? get email => _session?.email;

  Map<String, String> get publicHeaders => {
        'apikey': AppConfig.supabasePublishableKey,
        'Content-Type': 'application/json',
      };

  Map<String, String> get authHeaders {
    final token = _session?.accessToken;
    if (token == null || token.isEmpty) {
      throw const AuthException('Sessão expirada. Entre novamente.');
    }

    return {
      ...publicHeaders,
      'Authorization': 'Bearer $token',
    };
  }

  Uri _authUri(String path) =>
      Uri.parse('${AppConfig.supabaseUrl}/auth/v1/$path');

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    final userId = prefs.getString(_userIdKey);
    final email = prefs.getString(_emailKey);
    final expiresAtMillis = prefs.getInt(_expiresAtKey);

    if ([accessToken, refreshToken, userId, email, expiresAtMillis]
        .any((value) => value == null || (value is String && value.isEmpty))) {
      return;
    }

    _session = AuthSession(
      accessToken: accessToken!,
      refreshToken: refreshToken!,
      userId: userId!,
      email: email!,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAtMillis!),
    );

    final expiresSoon = _session!.expiresAt.isBefore(
      DateTime.now().add(const Duration(minutes: 1)),
    );

    if (expiresSoon) {
      try {
        await refreshSession();
      } catch (error) {
        debugPrint('ROTA auth restore: $error');
        await _clearSession();
      }
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _authUri('token?grant_type=password'),
      headers: publicHeaders,
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    if (response.statusCode >= 400) {
      throw AuthException(
        _messageFrom(response, fallback: 'E-mail ou senha inválidos.'),
      );
    }

    await _setSessionFromResponse(response);
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _authUri('signup'),
      headers: publicHeaders,
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    if (response.statusCode >= 400) {
      throw AuthException(
        _messageFrom(response, fallback: 'Não foi possível criar a conta.'),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = decoded['access_token'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    await _setSessionFromDecoded(decoded, fallbackEmail: email.trim());
    return true;
  }

  Future<void> signOut() async {
    try {
      if (_session != null) {
        await _client.post(
          _authUri('logout'),
          headers: authHeaders,
        );
      }
    } catch (_) {
      // A sessão local ainda deve ser encerrada mesmo sem conexão.
    } finally {
      await _clearSession();
      notifyListeners();
    }
  }

  Future<bool> ensureValidSession() async {
    if (_session == null) return false;

    final expiresSoon = _session!.expiresAt.isBefore(
      DateTime.now().add(const Duration(minutes: 1)),
    );

    if (expiresSoon) {
      await refreshSession();
    }

    return _session != null;
  }

  Future<void> refreshSession() async {
    final current = _session;
    if (current == null || current.refreshToken.isEmpty) {
      await _clearSession();
      throw const AuthException('Sua sessão expirou. Entre novamente.');
    }

    final response = await _client.post(
      _authUri('token?grant_type=refresh_token'),
      headers: publicHeaders,
      body: jsonEncode({'refresh_token': current.refreshToken}),
    );

    if (response.statusCode >= 400) {
      await _clearSession();
      throw AuthException(
        _messageFrom(
          response,
          fallback: 'Sua sessão expirou. Entre novamente.',
        ),
      );
    }

    await _setSessionFromResponse(response, fallbackEmail: current.email);
  }

  Future<void> _setSessionFromResponse(
    http.Response response, {
    String? fallbackEmail,
  }) async {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    await _setSessionFromDecoded(decoded, fallbackEmail: fallbackEmail);
  }

  Future<void> _setSessionFromDecoded(
    Map<String, dynamic> decoded, {
    String? fallbackEmail,
  }) async {
    final accessToken = decoded['access_token'] as String?;
    final refreshToken = decoded['refresh_token'] as String?;
    final expiresIn = decoded['expires_in'] as int? ?? 3600;
    final user = decoded['user'] as Map<String, dynamic>?;

    if (accessToken == null || refreshToken == null || user == null) {
      throw const AuthException(
        'O Supabase não retornou uma sessão válida.',
      );
    }

    final userId = user['id'] as String?;
    final email = (user['email'] as String?) ?? fallbackEmail;

    if (userId == null || email == null) {
      throw const AuthException('Não foi possível identificar sua conta.');
    }

    _session = AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      email: email,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );

    await _saveSession();
    notifyListeners();
  }

  Future<void> _saveSession() async {
    final current = _session;
    if (current == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, current.accessToken);
    await prefs.setString(_refreshTokenKey, current.refreshToken);
    await prefs.setString(_userIdKey, current.userId);
    await prefs.setString(_emailKey, current.email);
    await prefs.setInt(
      _expiresAtKey,
      current.expiresAt.millisecondsSinceEpoch,
    );
  }

  Future<void> _clearSession() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_expiresAtKey);
  }

  String _messageFrom(http.Response response, {required String fallback}) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        for (final key in [
          'msg',
          'message',
          'error_description',
          'error',
        ]) {
          final value = decoded[key];
          if (value is String && value.trim().isNotEmpty) {
            return value;
          }
        }
      }
    } catch (_) {
      // Resposta não JSON: mantém a mensagem padrão.
    }

    return fallback;
  }
}
