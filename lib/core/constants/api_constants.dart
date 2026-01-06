class ApiConstants {
  // Esta URL será obtenida dinámicamente desde Vercel
  static String? _supabaseUrl;
  static String? _supabaseAnonKey;
  static String? _geminiApiKey;

  // URL del endpoint de Vercel para obtener configuración
  // Actualizada al dominio desplegado en Vercel
  static const String vercelConfigUrl =
      'https://vercelpetauth.vercel.app/api/config';

  // Getters
  static String get supabaseUrl => _supabaseUrl ?? '';
  static String get supabaseAnonKey => _supabaseAnonKey ?? '';
  static String get geminiApiKey => _geminiApiKey ?? '';

  // Setters
  static void setSupabaseConfig(String url, String key) {
    _supabaseUrl = url;
    _supabaseAnonKey = key;
  }

  static void setGeminiApiKey(String key) {
    _geminiApiKey = key;
  }
}
