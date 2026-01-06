import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_shelter_by_id_usecase.dart';
import '../../domain/usecases/is_favorite_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import 'animal_detail_event.dart';
import 'animal_detail_state.dart';

class AnimalDetailBloc extends Bloc<AnimalDetailEvent, AnimalDetailState> {
  final GetShelterByIdUseCase getShelterByIdUseCase;
  final IsFavoriteUseCase isFavoriteUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  AnimalDetailBloc({
    required this.getShelterByIdUseCase,
    required this.isFavoriteUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(const AnimalDetailState()) {
    on<LoadShelterDetailsEvent>(_onLoadShelterDetails);
    on<CheckFavoriteStatusEvent>(_onCheckFavoriteStatus);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadShelterDetails(
    LoadShelterDetailsEvent event,
    Emitter<AnimalDetailState> emit,
  ) async {
    emit(state.copyWith(status: AnimalDetailStatus.loading));
    final result = await getShelterByIdUseCase(event.shelterId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnimalDetailStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (shelter) => emit(
        state.copyWith(status: AnimalDetailStatus.loaded, shelter: shelter),
      ),
    );
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatusEvent event,
    Emitter<AnimalDetailState> emit,
  ) async {
    final result = await isFavoriteUseCase(event.animalId);
    result.fold(
      (failure) => null,
      (isFav) => emit(state.copyWith(isFavorite: isFav)),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<AnimalDetailState> emit,
  ) async {
    final makeFavorite = !state.isFavorite;
    emit(state.copyWith(isFavorite: makeFavorite));

    final result = await toggleFavoriteUseCase(event.animalId);
    result.fold((failure) {
      emit(
        state.copyWith(
          isFavorite: !makeFavorite,
          errorMessage: 'Error actualizando favoritos',
        ),
      );
    }, (_) {});
  }
}
