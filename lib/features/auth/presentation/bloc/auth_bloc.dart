import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/update_role_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final UpdateRoleUseCase updateRoleUseCase;
  final LogoutUseCase logoutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleSignInUseCase,
    required this.updateRoleUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<UpdateRoleEvent>(_onUpdateRole);
    on<LogoutEvent>(_onLogout);
    on<ResetPasswordEvent>(_onResetPassword);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RefreshUserEvent>(_onRefreshUser);
  }

  Future<void> _onRefreshUser(
    RefreshUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    // NO emitimos AuthLoading para evitar parpadeos en la UI
    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) {
        // Si falla silenciosamente, no hacemos nada o podríamos loguear el error
        // pero mantenemos el estado actual si es posible
      },
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await loginUseCase(event.email, event.password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      event.email,
      event.password,
      event.name,
      event.role, // Pasar el rol al use case
    );

    await result.fold(
      (failure) async {
        // Si el error es de confirmación requerida, mostrar mensaje especial
        if (failure.message.contains('CONFIRMATION_REQUIRED')) {
          emit(
            const RegistrationPendingConfirmation(
              'Registro exitoso. Por favor, revisa tu correo electrónico para confirmar tu cuenta antes de iniciar sesión.',
            ),
          );
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) async {
        // Tras registro exitoso siempre pedir confirmación por email
        emit(
          const RegistrationPendingConfirmation(
            'Registro exitoso. Por favor, revisa tu correo electrónico para confirmar tu cuenta antes de iniciar sesión.',
          ),
        );
      },
    );
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await googleSignInUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onUpdateRole(
    UpdateRoleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await updateRoleUseCase(event.role);

    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (_) async {
        // Después de actualizar el rol, obtener el usuario actualizado
        final userResult = await getCurrentUserUseCase();
        userResult.fold(
          (failure) => emit(
            AuthError(
              'Rol actualizado pero error al obtener usuario: ${failure.message}',
            ),
          ),
          (user) {
            if (user != null) {
              emit(AuthAuthenticated(user));
            } else {
              emit(AuthUnauthenticated());
            }
          },
        );
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await resetPasswordUseCase(event.email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(
        const PasswordResetSent(
          'Se ha enviado un correo para restablecer tu contraseña',
        ),
      ),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getCurrentUserUseCase();

    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }
}
