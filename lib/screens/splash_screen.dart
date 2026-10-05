import 'package:flutter/material.dart';

import '../core/auth_service.dart';
import '../data/rota_store.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), _go);
  }

  Future<void> _go() async {
    if (!mounted) return;

    if (!widget.auth.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LoginScreen(auth: widget.auth),
        ),
      );
      return;
    }

    final store = RotaStore(auth: widget.auth);
    await store.bootstrap();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DashboardScreen(store: store),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Image.asset(
            'assets/images/rota_mark.png',
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
