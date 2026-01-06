import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'core/constants/api_constants.dart';
import 'core/utils/config_loader.dart';
import 'core/network/supabase_client.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/realtime_notification_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/role_selection_page.dart';
import 'features/refugio/presentation/pages/agregar_ubicacion_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar .env si existe
  try {
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    final geminiKey = dotenv.env['GEMINI_API_KEY'];

    if (url != null && key != null && url.isNotEmpty && key.isNotEmpty) {
      ApiConstants.setSupabaseConfig(url, key);
    }
    if (geminiKey != null && geminiKey.isNotEmpty) {
      ApiConstants.setGeminiApiKey(geminiKey);
    }
  } catch (_) {}

  // Intentar cargar configuración remota
  try {
    await ConfigLoader.loadConfig();
  } catch (_) {}

  // Inicializar Supabase
  await SupabaseClientHelper.initialize();
  print('***** Supabase init completed ${SupabaseClientHelper.client}');

  // Inicializar servicio de notificaciones
  await RealtimeNotificationService().initialize();
  print('***** Notification service initialized');

  // Inicializar inyección de dependencias
  await di.init();

  runApp(const PetaAdpotApp());
}

class PetaAdpotApp extends StatefulWidget {
  const PetaAdpotApp({Key? key}) : super(key: key);

  @override
  State<PetaAdpotApp> createState() => _PetaAdpotAppState();
}

class _PetaAdpotAppState extends State<PetaAdpotApp> {
  StreamSubscription? _authSubscription;
  StreamSubscription? _linkSubscription;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();

    // Inicializar AppLinks
    _appLinks = AppLinks();

    // Solo configurar deep links en móvil, NO en web
    if (!kIsWeb) {
      _setupMobileDeepLinks();
    } else {
      _setupWebAuth();
    }
  }

  // Configuración para MÓVIL
  void _setupMobileDeepLinks() {
    debugPrint('***** Configurando deep links para móvil con app_links');

    // Manejar deep link inicial
    _handleInitialUri();

    // Escuchar deep links mientras la app está abierta
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) async {
        if (uri != null) {
          await _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('Error en deep link: $err');
      },
    );
  }

  Future<void> _handleInitialUri() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        debugPrint('***** URI inicial detectada: $uri');
        await _handleDeepLink(uri);
      }
    } catch (e) {
      debugPrint('Error obteniendo URI inicial: $e');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('***** Deep link recibido: $uri');

    if (uri.scheme == 'petaadpot') {
      final fragment = uri.fragment;
      if (fragment.isEmpty) return;

      final params = Uri.splitQueryString(fragment);
      final accessToken = params['access_token'];
      final refreshToken = params['refresh_token'];

      if (accessToken != null) {
        try {
          debugPrint('***** Estableciendo sesión con tokens del deep link');
          // Establecer sesión con los tokens recibidos
          final response = await SupabaseClientHelper.client.auth
              .recoverSession('$accessToken:${refreshToken ?? ''}');

          if (response.session != null) {
            debugPrint('***** Sesión establecida correctamente');
            // Esperar a que se sincronice completamente
            await Future.delayed(const Duration(seconds: 1));
          }
        } catch (e) {
          debugPrint('Error estableciendo sesión: $e');
        }
      }
    }
  }

  // Configuración para WEB
  void _setupWebAuth() {
    debugPrint('***** Modo web: OAuth manejado automáticamente por Supabase');
    // En web, Supabase maneja automáticamente el callback de OAuth
    // No necesitamos configurar deep links ya que causaba el error
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
      child: MaterialApp(
        title: 'PetaAdpotApp',
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
        routes: {
          '/agregar_ubicacion': (_) => const AgregarUbicacionRefugioPage(),
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription? _authStateSubscription;
  final _realtimeService = RealtimeNotificationService();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios de estado de autenticación de Supabase
    // Cuando se complete el OAuth (deep link), esto será disparado
    _authStateSubscription = SupabaseClientHelper.client.auth.onAuthStateChange
        .listen((data) {
          final event = data.event;
          if (data.session != null) {
            debugPrint(
              '***** Sesión detectada en AuthGate ($event), actualizando BLoC',
            );
            // Cuando hay sesión, verificar el estado de autenticación
            if (mounted) {
              if (event == AuthChangeEvent.signedIn ||
                  event == AuthChangeEvent.initialSession) {
                context.read<AuthBloc>().add(CheckAuthStatusEvent());
                _realtimeService.startListening();
              } else if (event == AuthChangeEvent.userUpdated ||
                  event == AuthChangeEvent.tokenRefreshed) {
                // Actualización silenciosa (sin loading global)
                context.read<AuthBloc>().add(RefreshUserEvent());
              }
            }
          } else {
            // Si no hay sesión, detener escucha de notificaciones
            _realtimeService.stopListening();
          }
        });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _realtimeService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF8B5CF6),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (state is AuthAuthenticated) {
          // Verificar si el usuario tiene rol asignado
          final userRole = state.user.role;

          if (userRole == null || userRole.isEmpty) {
            // No tiene rol - mostrar página de selección
            return const RoleSelectionPage();
          }

          // Tiene rol - ir al home
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
