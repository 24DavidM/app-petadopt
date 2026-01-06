import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal_model.dart';
import '../models/request_model.dart';

abstract class RefugioRemoteDataSource {
  Future<List<AnimalModel>> getMyAnimals();
  Future<AnimalModel> getAnimalById(String id);
  Future<void> createAnimal({
    required String name,
    required String species,
    String? breed,
    String? age,
    String? gender,
    String? size,
    String? description,
    String? notes,
    List<String>? personality,
    List<String>? healthStatus,
    required List<String> imageUrls,
  });
  Future<void> updateAnimal({
    required String id,
    required String name,
    required String species,
    String? breed,
    String? age,
    String? gender,
    String? size,
    String? description,
    String? notes,
    List<String>? personality,
    List<String>? healthStatus,
    List<String>? imageUrls,
  });
  Future<void> deleteAnimal(String id);
  Future<bool> hasActiveRequests(String animalId);
  Future<List<RequestModel>> getRequests();
  Future<List<RequestModel>> getRequestsByStatus(String status);
  Future<void> approveRequest(String requestId);
  Future<void> rejectRequest(String requestId);
  Future<void> updateShelterLocation({
    required double latitude,
    required double longitude,
    required String address,
  });
  Future<List<String>> uploadImages(List<XFile> images);
}

class RefugioRemoteDataSourceImpl implements RefugioRemoteDataSource {
  final SupabaseClient supabaseClient;

  RefugioRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<AnimalModel>> getMyAnimals() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await supabaseClient
          .from('animals')
          .select('*')
          .eq('shelter_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AnimalModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo animales: $e');
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
  Future<void> createAnimal({
    required String name,
    required String species,
    String? breed,
    String? age,
    String? gender,
    String? size,
    String? description,
    String? notes,
    List<String>? personality,
    List<String>? healthStatus,
    required List<String> imageUrls,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await supabaseClient.from('animals').insert({
        'name': name,
        'species': species,
        'breed': breed,
        'age': age ?? 'Adulto',
        'gender': gender,
        'size': size,
        'description': description,
        'notes': notes,
        'personality': personality,
        'health_status': healthStatus,
        'image_urls': imageUrls,
        'status': 'available',
        'shelter_id': userId,
      });
    } catch (e) {
      throw Exception('Error creando animal: $e');
    }
  }

  @override
  Future<void> updateAnimal({
    required String id,
    required String name,
    required String species,
    String? breed,
    String? age,
    String? gender,
    String? size,
    String? description,
    String? notes,
    List<String>? personality,
    List<String>? healthStatus,
    List<String>? imageUrls,
  }) async {
    try {
      await supabaseClient
          .from('animals')
          .update({
            'name': name,
            'species': species,
            'breed': breed,
            'age': age ?? 'Adulto',
            'gender': gender,
            'size': size,
            'description': description,
            'notes': notes,
            'personality': personality,
            'health_status': healthStatus,
            'image_urls': imageUrls,
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Error actualizando animal: $e');
    }
  }

  @override
  Future<void> deleteAnimal(String id) async {
    try {
      await supabaseClient.from('animals').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error eliminando animal: $e');
    }
  }

  @override
  Future<bool> hasActiveRequests(String animalId) async {
    try {
      final response = await supabaseClient.rpc(
        'has_active_adoption_requests',
        params: {'animal_uuid': animalId},
      );

      return response as bool? ?? false;
    } catch (e) {
      throw Exception('Error verificando solicitudes: $e');
    }
  }

  @override
  Future<List<RequestModel>> getRequests() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener solicitudes con animales
      final response = await supabaseClient
          .from('adoption_requests')
          .select('*, animals(*)')
          .eq('shelter_id', userId)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response as List);

      // Obtener IDs únicos de adoptantes
      final adopterIds = <String>{};
      for (var request in data) {
        final adopterId = request['adopter_id'] as String?;
        if (adopterId != null) {
          adopterIds.add(adopterId);
        }
      }

      // Si hay adoptantes, obtener sus perfiles
      if (adopterIds.isNotEmpty) {
        final profiles = await supabaseClient
            .from('user_profiles')
            .select('id, email, full_name, phone, avatar_url')
            .inFilter('id', adopterIds.toList());

        final profilesMap = <String, Map<String, dynamic>>{};
        for (var profile in profiles) {
          profilesMap[profile['id'] as String] = profile;
        }

        // Agregar perfiles a solicitudes
        for (var request in data) {
          final adopterId = request['adopter_id'];
          if (profilesMap.containsKey(adopterId)) {
            request['user_profiles'] = profilesMap[adopterId];
          }
        }
      }

      return data.map((json) => RequestModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error obteniendo solicitudes: $e');
    }
  }

  @override
  Future<List<RequestModel>> getRequestsByStatus(String status) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener solicitudes con animales
      final response = await supabaseClient
          .from('adoption_requests')
          .select('*, animals(*)')
          .eq('shelter_id', userId)
          .eq('status', status)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response as List);

      // Obtener IDs únicos de adoptantes
      final adopterIds = <String>{};
      for (var request in data) {
        final adopterId = request['adopter_id'] as String?;
        if (adopterId != null) {
          adopterIds.add(adopterId);
        }
      }

      // Si hay adoptantes, obtener sus perfiles
      if (adopterIds.isNotEmpty) {
        final profiles = await supabaseClient
            .from('user_profiles')
            .select('id, email, full_name, phone, avatar_url')
            .inFilter('id', adopterIds.toList());

        final profilesMap = <String, Map<String, dynamic>>{};
        for (var profile in profiles) {
          profilesMap[profile['id'] as String] = profile;
        }

        // Agregar perfiles a solicitudes
        for (var request in data) {
          final adopterId = request['adopter_id'];
          if (profilesMap.containsKey(adopterId)) {
            request['user_profiles'] = profilesMap[adopterId];
          }
        }
      }

      return data.map((json) => RequestModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error obteniendo solicitudes por estado: $e');
    }
  }

  @override
  Future<void> approveRequest(String requestId) async {
    try {
      await supabaseClient
          .from('adoption_requests')
          .update({'status': 'approved'})
          .eq('id', requestId);
    } catch (e) {
      throw Exception('Error aprobando solicitud: $e');
    }
  }

  @override
  Future<void> rejectRequest(String requestId) async {
    try {
      await supabaseClient
          .from('adoption_requests')
          .update({'status': 'rejected'})
          .eq('id', requestId);
    } catch (e) {
      throw Exception('Error rechazando solicitud: $e');
    }
  }

  @override
  Future<void> updateShelterLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await supabaseClient.from('shelter_locations').upsert({
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'is_active': true,
      }, onConflict: 'user_id');
    } catch (e) {
      throw Exception('Error actualizando ubicación: $e');
    }
  }

  @override
  Future<List<String>> uploadImages(List<XFile> images) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final List<String> imageUrls = [];

      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        final bytes = await file.readAsBytes();
        final fileExt = file.name.split('.').last;
        final fileName =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.$fileExt';
        final path = '$userId/$fileName';

        await supabaseClient.storage
            .from('animal_images')
            .uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$fileExt'),
            );

        final url = supabaseClient.storage
            .from('animal_images')
            .getPublicUrl(path);

        imageUrls.add(url);
      }

      return imageUrls;
    } catch (e) {
      throw Exception('Error subiendo imágenes: $e');
    }
  }
}
