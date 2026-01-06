import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_animals_usecase.dart';
import '../../domain/usecases/create_animal_usecase.dart';
import '../../domain/usecases/update_animal_usecase.dart';
import '../../domain/usecases/delete_animal_usecase.dart';
import '../../domain/usecases/has_active_requests_usecase.dart';
import '../../domain/usecases/get_requests_usecase.dart';
import '../../domain/usecases/get_requests_by_status_usecase.dart';
import '../../domain/usecases/approve_request_usecase.dart';
import '../../domain/usecases/reject_request_usecase.dart';
import '../../domain/usecases/update_shelter_location_usecase.dart';
import 'refugio_event.dart';
import 'refugio_state.dart';

class RefugioBloc extends Bloc<RefugioEvent, RefugioState> {
  final GetMyAnimalsUseCase getMyAnimalsUseCase;
  final CreateAnimalUseCase createAnimalUseCase;
  final UpdateAnimalUseCase updateAnimalUseCase;
  final DeleteAnimalUseCase deleteAnimalUseCase;
  final HasActiveRequestsUseCase hasActiveRequestsUseCase;
  final GetRequestsUseCase getRequestsUseCase;
  final GetRequestsByStatusUseCase getRequestsByStatusUseCase;
  final ApproveRequestUseCase approveRequestUseCase;
  final RejectRequestUseCase rejectRequestUseCase;
  final UpdateShelterLocationUseCase updateShelterLocationUseCase;

  RefugioBloc({
    required this.getMyAnimalsUseCase,
    required this.createAnimalUseCase,
    required this.updateAnimalUseCase,
    required this.deleteAnimalUseCase,
    required this.hasActiveRequestsUseCase,
    required this.getRequestsUseCase,
    required this.getRequestsByStatusUseCase,
    required this.approveRequestUseCase,
    required this.rejectRequestUseCase,
    required this.updateShelterLocationUseCase,
  }) : super(RefugioInitial()) {
    on<LoadMyAnimalsEvent>(_onLoadMyAnimals);
    on<LoadRefugioDashboardEvent>(_onLoadRefugioDashboard);
    on<CreateAnimalEvent>(_onCreateAnimal);
    on<UpdateAnimalEvent>(_onUpdateAnimal);
    on<DeleteAnimalEvent>(_onDeleteAnimal);
    on<CheckActiveRequestsEvent>(_onCheckActiveRequests);
    on<LoadRequestsEvent>(_onLoadRequests);
    on<LoadRequestsByStatusEvent>(_onLoadRequestsByStatus);
    on<ApproveRequestEvent>(_onApproveRequest);
    on<RejectRequestEvent>(_onRejectRequest);
    on<UpdateLocationEvent>(_onUpdateLocation);
  }

  Future<void> _onLoadRefugioDashboard(
    LoadRefugioDashboardEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());

    // Ejecutar ambas consultas en paralelo
    final animalsResult = await getMyAnimalsUseCase();
    final requestsResult = await getRequestsUseCase();

    // Manejar resultados
    animalsResult.fold((failure) => emit(RefugioError(failure.message)), (
      animals,
    ) {
      requestsResult.fold((failure) => emit(RefugioError(failure.message)), (
        requests,
      ) {
        final totalAnimals = animals.length;
        final adoptedAnimals = animals
            .where((a) => a.status == 'adopted')
            .length;
        final pendingRequests = requests
            .where((r) => r.status == 'pending')
            .length;

        // Ordenar solicitudes por fecha (más recientes primero) y tomar las primeras 5
        // Asumiendo que RequestEntity tiene createdAt o similar, si no, usar el orden que venga
        // Si no hay fecha en entity, usar el orden de la lista
        final recentRequests = requests.take(5).toList();

        // Tomar los 3 animales más recientes agregados
        final recentAnimals = animals.take(3).toList();

        emit(
          RefugioDashboardLoaded(
            totalAnimals: totalAnimals,
            adoptedAnimals: adoptedAnimals,
            pendingRequests: pendingRequests,
            recentRequests: recentRequests,
            recentAnimals: recentAnimals,
          ),
        );
      });
    });
  }

  Future<void> _onLoadMyAnimals(
    LoadMyAnimalsEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await getMyAnimalsUseCase();
    result.fold(
      (failure) => emit(RefugioError(failure.message)),
      (animals) => emit(MyAnimalsLoaded(animals)),
    );
  }

  Future<void> _onCreateAnimal(
    CreateAnimalEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await createAnimalUseCase(
      name: event.name,
      species: event.species,
      breed: event.breed,
      age: event.age,
      gender: event.gender,
      size: event.size,
      description: event.description,
      notes: event.notes,
      personality: event.personality,
      healthStatus: event.healthStatus,
      images: event.images,
    );
    result.fold(
      (failure) => emit(RefugioError(failure.message)),
      (_) => emit(AnimalCreated()),
    );
  }

  Future<void> _onUpdateAnimal(
    UpdateAnimalEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await updateAnimalUseCase(
      id: event.id,
      name: event.name,
      species: event.species,
      breed: event.breed,
      age: event.age,
      gender: event.gender,
      size: event.size,
      description: event.description,
      notes: event.notes,
      personality: event.personality,
      healthStatus: event.healthStatus,
      newImages: event.newImages,
      existingImageUrls: event.existingImageUrls,
    );
    result.fold(
      (failure) => emit(RefugioError(failure.message)),
      (_) => emit(AnimalUpdated()),
    );
  }

  Future<void> _onDeleteAnimal(
    DeleteAnimalEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await deleteAnimalUseCase(event.id);
    result.fold(
      (failure) => emit(RefugioError(failure.message)),
      (_) => emit(AnimalDeleted()),
    );
  }

  Future<void> _onCheckActiveRequests(
    CheckActiveRequestsEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await hasActiveRequestsUseCase(event.animalId);
    result.fold(
      (failure) => emit(RefugioError(failure.message)),
      (hasRequests) => emit(ActiveRequestsChecked(hasRequests)),
    );
  }

  Future<void> _onLoadRequests(
    LoadRequestsEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await getRequestsUseCase();
    result.fold(
      (failure) => emit(RefugioError(failure.message)),
      (requests) => emit(RequestsLoaded(requests)),
    );
  }

  Future<void> _onLoadRequestsByStatus(
    LoadRequestsByStatusEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await getRequestsByStatusUseCase(event.status);
    result.fold(
      (failure) => emit(RefugioError(failure.message)),
      (requests) => emit(RequestsLoaded(requests)),
    );
  }

  Future<void> _onApproveRequest(
    ApproveRequestEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await approveRequestUseCase(event.requestId);
    result.fold((failure) => emit(RefugioError(failure.message)), (_) async {
      // Después de aprobar, recargar la lista de solicitudes
      final requestsResult = await getRequestsUseCase();
      requestsResult.fold(
        (failure) => emit(RefugioError(failure.message)),
        (requests) => emit(RequestsLoaded(requests)),
      );
    });
  }

  Future<void> _onRejectRequest(
    RejectRequestEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await rejectRequestUseCase(event.requestId);
    result.fold((failure) => emit(RefugioError(failure.message)), (_) async {
      // Después de rechazar, recargar la lista de solicitudes
      final requestsResult = await getRequestsUseCase();
      requestsResult.fold(
        (failure) => emit(RefugioError(failure.message)),
        (requests) => emit(RequestsLoaded(requests)),
      );
    });
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<RefugioState> emit,
  ) async {
    emit(RefugioLoading());
    final result = await updateShelterLocationUseCase(
      latitude: event.latitude,
      longitude: event.longitude,
      address: event.address,
    );
    result.fold(
      (failure) => emit(RefugioError(failure.message)),
      (_) => emit(LocationUpdated()),
    );
  }
}
