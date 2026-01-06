import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Inicializar zonas horarias
    tz.initializeTimeZones();

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializar plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permisos en Android 13+
    await _requestPermissions();

    _isInitialized = true;
  }

  /// Solicitar permisos de notificaciones
  Future<void> _requestPermissions() async {
    // Android 13+ requiere permisos explícitos
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS requiere permisos
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Mostrar notificación inmediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'adoption_channel',
      'Adopciones',
      channelDescription: 'Notificaciones de solicitudes de adopción',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Mostrar notificación de nueva solicitud (para refugios)
  Future<void> showNewRequestNotification({
    required String animalName,
    required String adopterName,
    required String requestId,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '¡Nueva Solicitud de Adopción!',
      body: '$adopterName quiere adoptar a $animalName',
      payload: 'request:$requestId',
    );
  }

  /// Mostrar notificación de solicitud aprobada (para adoptantes)
  Future<void> showApprovedRequestNotification({
    required String animalName,
    required String requestId,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '¡Solicitud Aprobada! 🎉',
      body: 'Tu solicitud para adoptar a $animalName ha sido aprobada',
      payload: 'request:$requestId',
    );
  }

  /// Mostrar notificación de solicitud rechazada (para adoptantes)
  Future<void> showRejectedRequestNotification({
    required String animalName,
    required String requestId,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Solicitud No Aprobada',
      body: 'Tu solicitud para adoptar a $animalName no fue aprobada',
      payload: 'request:$requestId',
    );
  }

  /// Cancelar una notificación específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Manejar toque en notificación
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      print('Notificación tocada con payload: $payload');
      // Aquí puedes navegar a la pantalla correspondiente
      // Por ejemplo, usando un NavigatorKey global
    }
  }
}
