/// Configuração do protótipo.
///
/// Supabase: cole a URL do projeto em `defaultValue` (Project Settings → API).
/// Também dá para injetar na hora: `--dart-define=SUPABASE_URL=https://xxxx.supabase.co`.
/// Com a URL vazia, o app usa só os dados locais.
class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_SznLxpqFupQ81auLjMAgxQ_ed8JnqoG',
  );

  static bool get hasSupabase => supabaseUrl.trim().isNotEmpty;

  /// Data "de hoje" do semestre mockado, para a apresentação ficar estável.
  static DateTime get demoToday => DateTime(2026, 9, 21);
}
