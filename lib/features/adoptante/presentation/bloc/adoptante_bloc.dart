import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_animals_usecase.dart';
import '../../domain/usecases/get_animals_by_species_usecase.dart';
import '../../domain/usecases/get_animal_by_id_usecase.dart';
import '../../domain/usecases/create_adoption_request_usecase.dart';
import '../../domain/usecases/get_my_requests_usecase.dart';
import '../../domain/usecases/cancel_request_usecase.dart';
import 'adoptante_event.dart';
import 'adoptante_state.dart';

class AdoptanteBloc extends Bloc<AdoptanteEvent, AdoptanteState> {
  final GetAnimalsUseCase getAnimalsUseCase;
  final GetAnimalsBySpeciesUseCase getAnimalsBySpeciesUseCase;
  final GetAnimalByIdUseCase getAnimalByIdUseCase;
  final CreateAdoptionRequestUseCase createAdoptionRequestUseCase;
  final GetMyRequestsUseCase getMyRequestsUseCase;
  final CancelRequestUseCase cancelRequestUseCase;

  AdoptanteBloc({
    required this.getAnimalsUseCase,
    required this.getAnimalsBySpeciesUseCase,
    required this.getAnimalByIdUseCase,
    required this.createAdoptionRequestUseCase,
    required this.getMyRequestsUseCase,
    required this.cancelRequestUseCase,
  }) : super(AdoptanteInitial()) {
    on<LoadAnimalsEvent>(_onLoadAnimals);
    on<LoadAnimalsBySpeciesEvent>(_onLoadAnimalsBySpecies);
    on<LoadAnimalByIdEvent>(_onLoadAnimalById);
    on<CreateAdoptionRequestEvent>(_onCreateAdoptionRequest);
    on<LoadMyRequestsEvent>(_onLoadMyRequests);
    on<CancelRequestEvent>(_onCancelRequest);
  }

  Future<void> _onLoadAnimals(
    LoadAnimalsEvent event,
    Emitter<AdoptanteState> emit,
  ) async {
    emit(AdoptanteLoading());
    final result = await getAnimalsUseCase();
    result.fold(
      (failure) => emit(AdoptanteError(failure.message)),
      (animals) => emit(AnimalsLoaded(animals)),
    );
  }

  Future<void> _onLoadAnimalsBySpecies(
    LoadAnimalsBySpeciesEvent event,
    Emitter<AdoptanteState> emit,
  ) async {
    emit(AdoptanteLoading());
    final result = await getAnimalsBySpeciesUseCase(event.species);
    result.fold(
      (failure) => emit(AdoptanteError(failure.message)),
      (animals) => emit(AnimalsLoaded(animals)),
    );
  }

  Future<void> _onLoadAnimalById(
    LoadAnimalByIdEvent event,
    Emitter<AdoptanteState> emit,
  ) async {
    emit(AdoptanteLoading());
    final result = await getAnimalByIdUseCase(event.id);
    result.fold(
      (failure) => emit(AdoptanteError(failure.message)),
      (animal) => emit(AnimalLoaded(animal)),
    );
  }

  Future<void> _onCreateAdoptionRequest(
    CreateAdoptionRequestEvent event,
    Emitter<AdoptanteState> emit,
  ) async {
    emit(AdoptanteLoading());
    final result = await createAdoptionRequestUseCase(
      animalId: event.animalId,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(AdoptanteError(failure.message)),
      (_) => emit(AdoptionRequestCreated()),
    );
  }

  Future<void> _onLoadMyRequests(
    LoadMyRequestsEvent event,
    Emitter<AdoptanteState> emit,
  ) async {
    emit(AdoptanteLoading());
    final result = await getMyRequestsUseCase();
    result.fold(
      (failure) => emit(AdoptanteError(failure.message)),
      (requests) => emit(MyRequestsLoaded(requests)),
    );
  }

  Future<void> _onCancelRequest(
    CancelRequestEvent event,
    Emitter<AdoptanteState> emit,
  ) async {
    emit(AdoptanteLoading());
    final result = await cancelRequestUseCase(event.requestId);
    result.fold(
      (failure) => emit(AdoptanteError(failure.message)),
      (_) => emit(RequestCancelled()),
    );
  }
}
