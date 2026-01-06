import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ConfigLoader {
  static Future<void> loadConfig() async {
    try {
      // If the vercelConfigUrl is still the placeholder, skip remote load
      if (ApiConstants.vercelConfigUrl.contains('YOUR_VERCEL_URL') ||
          ApiConstants.vercelConfigUrl.isEmpty) {
        return;
      }

      final response = await http
          .get(Uri.parse(ApiConstants.vercelConfigUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ServerException(
          'Error al obtener configuración: ${response.statusCode}',
        );
      }

      // Defensively parse JSON; if the response isn't JSON (e.g. HTML),
      // log and skip overriding local config.
      try {
        final data = json.decode(response.body);
        final supabaseUrl = data['supabaseUrl'] as String?;
        final supabaseAnonKey = data['supabaseAnonKey'] as String?;
        final geminiApiKey = data['geminiApiKey'] as String?;

        if (supabaseUrl == null || supabaseAnonKey == null) {
          throw ServerException('Configuración incompleta desde Vercel');
        }

        ApiConstants.setSupabaseConfig(supabaseUrl, supabaseAnonKey);

        if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
          ApiConstants.setGeminiApiKey(geminiApiKey);
        }
      } on FormatException catch (e) {
        // Response is not valid JSON (e.g. HTML error page). Don't throw,
        // just log so app can continue using local .env values.
        throw ServerException('Respuesta inválida desde Vercel: $e');
      }
    } catch (e) {
      throw ServerException('No se pudo cargar la configuración: $e');
    }
  }
}
