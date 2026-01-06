import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_constants.dart';

class SupabaseClientHelper {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase no ha sido inicializado');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    if (ApiConstants.supabaseUrl.isEmpty ||
        ApiConstants.supabaseAnonKey.isEmpty) {
      throw Exception('Las credenciales de Supabase no están configuradas');
    }

    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }
}
