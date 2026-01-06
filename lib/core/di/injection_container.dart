import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/google_signin_usecase.dart';
import '../../features/auth/domain/usecases/update_role_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Adoptante
import '../../features/adoptante/data/datasources/adoptante_remote_data_source.dart';
import '../../features/adoptante/data/repositories/adoptante_repository_impl.dart';
import '../../features/adoptante/domain/repositories/adoptante_repository.dart';
import '../../features/adoptante/domain/usecases/get_animals_usecase.dart';
import '../../features/adoptante/domain/usecases/get_animals_by_species_usecase.dart';
import '../../features/adoptante/domain/usecases/get_animal_by_id_usecase.dart';
import '../../features/adoptante/domain/usecases/create_adoption_request_usecase.dart';
import '../../features/adoptante/domain/usecases/get_my_requests_usecase.dart';
import '../../features/adoptante/domain/usecases/cancel_request_usecase.dart';
import '../../features/adoptante/presentation/bloc/adoptante_bloc.dart';
import '../../features/adoptante/presentation/bloc/animal_detail_bloc.dart';

// Refugio
import '../../features/refugio/data/datasources/refugio_remote_data_source.dart';
import '../../features/refugio/data/repositories/refugio_repository_impl.dart';
import '../../features/refugio/domain/repositories/refugio_repository.dart';
import '../../features/refugio/domain/usecases/get_my_animals_usecase.dart';
import '../../features/refugio/domain/usecases/create_animal_usecase.dart';
import '../../features/refugio/domain/usecases/update_animal_usecase.dart';
import '../../features/refugio/domain/usecases/delete_animal_usecase.dart';
import '../../features/refugio/domain/usecases/has_active_requests_usecase.dart';
import '../../features/refugio/domain/usecases/get_requests_usecase.dart';
import '../../features/refugio/domain/usecases/get_requests_by_status_usecase.dart';
import '../../features/refugio/domain/usecases/approve_request_usecase.dart';
import '../../features/refugio/domain/usecases/reject_request_usecase.dart';
import '../../features/refugio/domain/usecases/update_shelter_location_usecase.dart';
import '../../features/refugio/presentation/bloc/refugio_bloc.dart';

// Adoptante - Mapa
import '../../features/adoptante/data/datasources/location_data_source.dart';
import '../../features/adoptante/data/datasources/shelter_data_source.dart';
import '../../features/adoptante/data/repositories/mapa_repository_impl.dart';
import '../../features/adoptante/domain/repositories/mapa_repository.dart';
import '../../features/adoptante/domain/usecases/get_current_location_usecase.dart';
import '../../features/adoptante/domain/usecases/get_nearby_shelters_usecase.dart';
import '../../features/adoptante/domain/usecases/get_shelter_by_id_usecase.dart';
import '../../features/adoptante/domain/usecases/is_favorite_usecase.dart';
import '../../features/adoptante/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/adoptante/presentation/bloc/mapa_bloc.dart';

// Adoptante - Chat IA
import '../../features/adoptante/data/datasources/gemini_data_source.dart';
import '../../features/adoptante/data/repositories/chat_repository_impl.dart';
import '../../features/adoptante/domain/repositories/chat_repository.dart';
import '../../features/adoptante/domain/usecases/send_message_usecase.dart';
import '../../features/adoptante/domain/usecases/get_chat_history_usecase.dart';
import '../../features/adoptante/domain/usecases/clear_chat_history_usecase.dart';
import '../../features/adoptante/presentation/bloc/chat_bloc.dart';

import '../network/network_info.dart';
import '../network/supabase_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============ Features - Auth ============

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      googleSignInUseCase: sl(),
      updateRoleUseCase: sl(),
      logoutUseCase: sl(),
      resetPasswordUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRoleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ============ Features - Adoptante ============

  // Bloc
  sl.registerFactory(
    () => AdoptanteBloc(
      getAnimalsUseCase: sl(),
      getAnimalsBySpeciesUseCase: sl(),
      getAnimalByIdUseCase: sl(),
      createAdoptionRequestUseCase: sl(),
      getMyRequestsUseCase: sl(),
      cancelRequestUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AnimalDetailBloc(
      getShelterByIdUseCase: sl(),
      isFavoriteUseCase: sl(),
      toggleFavoriteUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAnimalsUseCase(sl()));
  sl.registerLazySingleton(() => GetAnimalsBySpeciesUseCase(sl()));
  sl.registerLazySingleton(() => GetAnimalByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateAdoptionRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetMyRequestsUseCase(sl()));
  sl.registerLazySingleton(() => CancelRequestUseCase(sl()));
  sl.registerLazySingleton(() => IsFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AdoptanteRepository>(
    () => AdoptanteRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AdoptanteRemoteDataSource>(
    () => AdoptanteRemoteDataSourceImpl(
      supabaseClient: SupabaseClientHelper.client,
    ),
  );

  // ============ Features - Refugio ============

  // Bloc
  sl.registerFactory(
    () => RefugioBloc(
      getMyAnimalsUseCase: sl(),
      createAnimalUseCase: sl(),
      updateAnimalUseCase: sl(),
      deleteAnimalUseCase: sl(),
      hasActiveRequestsUseCase: sl(),
      getRequestsUseCase: sl(),
      getRequestsByStatusUseCase: sl(),
      approveRequestUseCase: sl(),
      rejectRequestUseCase: sl(),
      updateShelterLocationUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMyAnimalsUseCase(sl()));
  sl.registerLazySingleton(() => CreateAnimalUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAnimalUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAnimalUseCase(sl()));
  sl.registerLazySingleton(() => HasActiveRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetRequestsByStatusUseCase(sl()));
  sl.registerLazySingleton(() => ApproveRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectRequestUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShelterLocationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<RefugioRepository>(
    () => RefugioRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<RefugioRemoteDataSource>(
    () => RefugioRemoteDataSourceImpl(
      supabaseClient: SupabaseClientHelper.client,
    ),
  );

  // ============ Features - Mapa ============

  // Bloc
  sl.registerFactory(
    () => MapaBloc(
      getCurrentLocationUseCase: sl(),
      getNearbySheltersUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentLocationUseCase(sl()));
  sl.registerLazySingleton(() => GetNearbySheltersUseCase(sl()));
  sl.registerLazySingleton(() => GetShelterByIdUseCase(sl()));

  // Repository
  sl.registerLazySingleton<MapaRepository>(
    () => MapaRepositoryImpl(locationDataSource: sl(), shelterDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSourceImpl());

  sl.registerLazySingleton<ShelterDataSource>(
    () => ShelterDataSourceImpl(supabaseClient: sl()),
  );

  // ============ Features - Chat IA ============

  // Bloc
  sl.registerFactory(
    () => ChatBloc(
      sendMessageUseCase: sl(),
      getChatHistoryUseCase: sl(),
      clearChatHistoryUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
  sl.registerLazySingleton(() => ClearChatHistoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(geminiDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<GeminiDataSource>(() => GeminiDataSourceImpl());

  // ============ Core ============

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Registrar SupabaseClient
  sl.registerLazySingleton(() => SupabaseClientHelper.client);

  // ============ External ============

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
