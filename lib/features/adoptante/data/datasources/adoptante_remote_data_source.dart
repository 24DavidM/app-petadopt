import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal_model.dart';
import '../models/adoption_request_model.dart';

abstract class AdoptanteRemoteDataSource {
  Future<List<AnimalModel>> getAnimals();
  Future<List<AnimalModel>> getAnimalsBySpecies(String species);
  Future<AnimalModel> getAnimalById(String id);
  Future<void> createAdoptionRequest({
    required String animalId,
    required String notes,
  });
  Future<List<AdoptionRequestModel>> getMyRequests();
  Future<void> cancelRequest(String requestId);
  Future<bool> isFavorite(String animalId);
  Future<void> toggleFavorite(String animalId);
}

class AdoptanteRemoteDataSourceImpl implements AdoptanteRemoteDataSource {
  final SupabaseClient supabaseClient;

  AdoptanteRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<AnimalModel>> getAnimals() async {
    try {
      final response = await supabaseClient
          .from('animals')
          .select('*')
          .eq('status', 'available')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AnimalModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo animales: $e');
    }
  }

  @override
  Future<List<AnimalModel>> getAnimalsBySpecies(String species) async {
    try {
      final response = await supabaseClient
          .from('animals')
          .select('*')
          .eq('status', 'available')
          .eq('species', species)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AnimalModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo animales por especie: $e');
    }
  }

  @override
  Future<AnimalModel> getAnimalById(String id) async {
    try {
      final response = await supabaseClient
          .from('animals')
          .select('*')
          .eq('id', id)
          .single();

      return AnimalModel.fromJson(response);
    } catch (e) {
      throw Exception('Error obteniendo animal: $e');
    }
  }

  @override
  Future<void> createAdoptionRequest({
    required String animalId,
    required String notes,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener shelter_id del animal
      final animal = await supabaseClient
          .from('animals')
          .select('shelter_id')
          .eq('id', animalId)
          .single();

      await supabaseClient.from('adoption_requests').insert({
        'animal_id': animalId,
        'adopter_id': userId,
        'shelter_id': animal['shelter_id'],
        'status': 'pending',
        'notes': notes,
      });
    } catch (e) {
      throw Exception('Error creando solicitud: $e');
    }
  }

  @override
  Future<List<AdoptionRequestModel>> getMyRequests() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener solicitudes con animales
      final response = await supabaseClient
          .from('adoption_requests')
          .select('*, animals(*)')
          .eq('adopter_id', userId)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response as List);

      // Extraer IDs únicos de refugios
      final shelterIds = <String>{};
      for (var request in data) {
        final shelterId = request['shelter_id'] as String?;
        if (shelterId != null) {
          shelterIds.add(shelterId);
        }
      }

      // Si hay refugios, obtener sus datos
      if (shelterIds.isNotEmpty) {
        final shelterProfiles = await supabaseClient
            .from('user_profiles')
            .select('id, full_name')
            .inFilter('id', shelterIds.toList());

        final shelterMap = <String, String>{};
        for (var profile in shelterProfiles) {
          shelterMap[profile['id'] as String] =
              profile['full_name'] as String? ?? 'Refugio';
        }

        // Agregar nombres de refugios a solicitudes
        for (var request in data) {
          final shelterId = request['shelter_id'] as String?;
          if (shelterId != null && shelterMap.containsKey(shelterId)) {
            request['shelter_name'] = shelterMap[shelterId];
          }
        }
      }

      return data
          .map(
            (json) =>
                AdoptionRequestModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo solicitudes: $e');
    }
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    try {
      await supabaseClient
          .from('adoption_requests')
          .update({'status': 'cancelled'})
          .eq('id', requestId);
    } catch (e) {
      throw Exception('Error cancelando solicitud: $e');
    }
  }

  @override
  Future<bool> isFavorite(String animalId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await supabaseClient
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('animal_id', animalId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error checking favorite: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String animalId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final exists = await isFavorite(animalId);

      if (exists) {
        await supabaseClient
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('animal_id', animalId);
      } else {
        await supabaseClient.from('favorites').insert({
          'user_id': userId,
          'animal_id': animalId,
        });
      }
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
  }
}
