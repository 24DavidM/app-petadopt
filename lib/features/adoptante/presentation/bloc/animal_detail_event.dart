import 'package:equatable/equatable.dart';

abstract class AnimalDetailEvent extends Equatable {
  const AnimalDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadShelterDetailsEvent extends AnimalDetailEvent {
  final String shelterId;
  const LoadShelterDetailsEvent(this.shelterId);
  @override
  List<Object> get props => [shelterId];
}

class CheckFavoriteStatusEvent extends AnimalDetailEvent {
  final String animalId;
  const CheckFavoriteStatusEvent(this.animalId);
  @override
  List<Object> get props => [animalId];
}

class ToggleFavoriteEvent extends AnimalDetailEvent {
  final String animalId;
  const ToggleFavoriteEvent(this.animalId);
  @override
  List<Object> get props => [animalId];
}
