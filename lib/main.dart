import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_theme.dart';
import 'core/auth_service.dart';
import 'screens/splash_screen.dart';
import 'widgets/phone_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final auth = AuthService();
  await auth.restoreSession();

  runApp(RotaApp(auth: auth));
}

class RotaApp extends StatelessWidget {
  const RotaApp({super.key, required this.auth});

  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROTA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      builder: (context, child) =>
          PhoneShell(child: child ?? const SizedBox.shrink()),
      home: SplashScreen(auth: auth),
    );
  }
}
