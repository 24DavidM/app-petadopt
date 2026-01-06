import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String email,
    String password,
    String name,
    String role,
  );
  Future<UserModel> signInWithGoogle();
  Future<void> updateUserRole(String role);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client = SupabaseClientHelper.client;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppAuthException('Error al iniciar sesión');
      }

      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException('Error inesperado al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'full_name': name,
          'role': role, // Incluir el rol en metadata
        },
      );

      if (response.user == null) {
        throw AppAuthException('Error al registrarse');
      }

      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } on AppAuthException {
      rethrow; // Re-lanzar sin modificar
    } catch (e) {
      throw AppAuthException(
        'Error inesperado al registrarse: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Diferentes redirects según la plataforma:
      // - Web: Redirigir a la URL base de tu app web (Supabase añadirá tokens al hash)
      // - Móvil: Usar deep link para recibir tokens directamente en la app
      final String redirectTo;

      if (kIsWeb) {
        // En web: redirigir a la URL base de tu app
        redirectTo = 'https://vercelpetauth.vercel.app/';
      } else {
        // En móvil: usar deep link scheme
        redirectTo = 'petaadpot://auth-callback';
      }

      debugPrint('***** Google OAuth redirectTo: $redirectTo');

      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw AppAuthException('Error al iniciar sesión con Google');
      }

      debugPrint('***** Google OAuth response: $response');

      // En web, esperar a que se complete el flujo OAuth
      await Future.delayed(const Duration(seconds: 2));

      // Verificar si el usuario está autenticado (funciona para web y móvil)
      final user = _client.auth.currentUser;
      if (user == null) {
        throw AppAuthException(
          'No se pudo obtener el usuario después del login',
        );
      }

      return UserModel.fromJson(user.toJson());
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Error inesperado con Google: $e');
    }
  }

  @override
  Future<void> updateUserRole(String role) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppAuthException('Usuario no autenticado');
      }

      debugPrint('***** Actualizando rol a: $role para usuario: $userId');

      // 1. Actualizar user_metadata primero
      await _client.auth.updateUser(UserAttributes(data: {'role': role}));

      debugPrint('***** User metadata actualizado');

      // 2. Actualizar tabla user_profiles usando la función SQL
      await _client.rpc(
        'sync_user_role',
        params: {'user_id': userId, 'new_role': role},
      );

      debugPrint('***** Tabla user_profiles actualizada via RPC');

      // Esperar un poco para que se sincronice
      await Future.delayed(const Duration(milliseconds: 500));
    } on PostgrestException catch (e) {
      debugPrint('***** Error PostgrestException: ${e.message}');
      throw AppAuthException(
        'Error al actualizar rol en base de datos: ${e.message}',
      );
    } on AuthException catch (e) {
      debugPrint('***** Error AuthException: ${e.message}');
      throw AppAuthException('Error al actualizar rol en auth: ${e.message}');
    } catch (e) {
      debugPrint('***** Error general: $e');
      throw AppAuthException('Error al actualizar rol: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Obtener información adicional de user_profiles
      final userId = user.id;
      final profileData = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      // Combinar datos de auth.users con user_profiles
      final userData = user.toJson();

      // Si hay datos del perfil, usar el rol de ahí (es más confiable)
      if (profileData != null && profileData['role'] != null) {
        userData['user_metadata'] = userData['user_metadata'] ?? {};
        userData['user_metadata']['role'] = profileData['role'];
        userData['user_metadata']['full_name'] = profileData['full_name'];
        userData['user_metadata']['phone'] = profileData['phone'];
        userData['user_metadata']['avatar_url'] = profileData['avatar_url'];
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      throw AppAuthException('Error al obtener usuario actual: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppAuthException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://vercelpetauth.vercel.app/reset-password.html',
      );
    } catch (e) {
      throw AppAuthException('Error al restablecer contraseña: $e');
    }
  }
}
