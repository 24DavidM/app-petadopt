import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/get_nearby_shelters_usecase.dart';
import 'mapa_event.dart';
import 'mapa_state.dart';

class MapaBloc extends Bloc<MapaEvent, MapaState> {
  final GetCurrentLocationUseCase getCurrentLocationUseCase;
  final GetNearbySheltersUseCase getNearbySheltersUseCase;

  MapaBloc({
    required this.getCurrentLocationUseCase,
    required this.getNearbySheltersUseCase,
  }) : super(MapaInitial()) {
    on<LoadCurrentLocationEvent>(_onLoadCurrentLocation);
    on<LoadNearbySheltersEvent>(_onLoadNearbyShelters);
  }

  Future<void> _onLoadCurrentLocation(
    LoadCurrentLocationEvent event,
    Emitter<MapaState> emit,
  ) async {
    emit(MapaLoading());

    final result = await getCurrentLocationUseCase();

    result.fold((failure) => emit(MapaError(failure.message)), (
      location,
    ) async {
      emit(LocationLoaded(location));

      // Cargar refugios cercanos automáticamente
      add(
        LoadNearbySheltersEvent(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      );
    });
  }

  Future<void> _onLoadNearbyShelters(
    LoadNearbySheltersEvent event,
    Emitter<MapaState> emit,
  ) async {
    emit(MapaLoading());

    final result = await getNearbySheltersUseCase(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusKm: event.radiusKm,
    );

    result.fold(
      (failure) => emit(MapaError(failure.message)),
      (shelters) => emit(
        SheltersLoaded(
          userLocation: LocationEntity(
            latitude: event.latitude,
            longitude: event.longitude,
          ),
          shelters: shelters,
        ),
      ),
    );
  }
}
