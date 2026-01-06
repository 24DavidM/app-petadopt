import 'package:equatable/equatable.dart';
import '../../domain/entities/shelter_entity.dart';

enum AnimalDetailStatus { initial, loading, loaded, error }

class AnimalDetailState extends Equatable {
  final AnimalDetailStatus status;
  final ShelterEntity? shelter;
  final bool isFavorite;
  final String? errorMessage;

  const AnimalDetailState({
    this.status = AnimalDetailStatus.initial,
    this.shelter,
    this.isFavorite = false,
    this.errorMessage,
  });

  AnimalDetailState copyWith({
    AnimalDetailStatus? status,
    ShelterEntity? shelter,
    bool? isFavorite,
    String? errorMessage,
  }) {
    return AnimalDetailState(
      status: status ?? this.status,
      shelter: shelter ?? this.shelter,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, shelter, isFavorite, errorMessage];
}
