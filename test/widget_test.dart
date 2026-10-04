import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rota_app/data/rota_store.dart';
import 'package:rota_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('abre o ROTA e chega no mapa de carga', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('pt_BR');
    final store = RotaStore();
    await store.bootstrap();
    await tester.pumpWidget(RotaApp(store: store));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Hercules'), findsOneWidget);
    expect(find.text('Carga acumulada'), findsOneWidget);
    expect(find.text('Semana 3 Crítica!'), findsOneWidget);
    expect(find.text('Projeto Figma'), findsWidgets);
  });
}
