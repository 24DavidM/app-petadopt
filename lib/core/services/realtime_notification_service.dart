import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class RealtimeNotificationService {
  static final RealtimeNotificationService _instance =
      RealtimeNotificationService._internal();
  factory RealtimeNotificationService() => _instance;
  RealtimeNotificationService._internal();

  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  RealtimeChannel? _notificationsChannel;

  /// Inicializar el servicio
  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  /// Escuchar notificaciones en tiempo real para el usuario actual
  void startListening() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      print('No hay usuario autenticado para escuchar notificaciones');
      return;
    }

    // Cancelar canal anterior si existe
    stopListening();

    // Crear nuevo canal de Realtime
    _notificationsChannel = _supabase
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            _handleNotificationInsert(payload);
          },
        )
        .subscribe();

    print('🔔 Escuchando notificaciones en tiempo real para: $userId');
  }

  /// Manejar inserción de nueva notificación
  void _handleNotificationInsert(PostgresChangePayload payload) {
    final newData = payload.newRecord;
    if (newData.isEmpty) return;

    final title = newData['title'] as String? ?? 'Nueva Notificación';
    final body = newData['body'] as String? ?? '';
    final type = newData['type'] as String? ?? '';
    final relatedId = newData['related_id'] as String? ?? '';

    print('📬 Nueva notificación recibida: $type - $title');

    // Mostrar notificación local según el tipo
    switch (type) {
      case 'new_request':
        // Para refugios: nueva solicitud
        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          title: title,
          body: body,
          payload: 'request:$relatedId',
        );
        break;

      case 'request_approved':
        // Para adoptantes: solicitud aprobada
        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          title: title,
          body: body,
          payload: 'request:$relatedId',
        );
        break;

      case 'request_rejected':
        // Para adoptantes: solicitud rechazada
        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          title: title,
          body: body,
          payload: 'request:$relatedId',
        );
        break;

      default:
        // Notificación genérica
        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          title: title,
          body: body,
          payload: relatedId,
        );
    }
  }

  /// Detener la escucha de notificaciones
  void stopListening() {
    if (_notificationsChannel != null) {
      _supabase.removeChannel(_notificationsChannel!);
      _notificationsChannel = null;
      print('🔕 Dejando de escuchar notificaciones');
    }
  }

  /// Marcar notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marcando notificación como leída: $e');
    }
  }

  /// Obtener notificaciones no leídas
  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error obteniendo notificaciones: $e');
      return [];
    }
  }

  /// Limpiar todas las notificaciones leídas
  Future<void> clearReadNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_read', true);
    } catch (e) {
      print('Error limpiando notificaciones: $e');
    }
  }
}
