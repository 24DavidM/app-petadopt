import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shelter_model.dart';

abstract class ShelterDataSource {
  /// Get nearby shelters using Supabase RPC function
  /// Uses get_nearby_shelters(user_lat, user_lon, radius_km)
  /// This function validates role='refugio' and is_active=true
  Future<List<ShelterModel>> getNearbyShelters({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  });

  /// Get current user's shelter location (for refugios)
  Future<ShelterModel?> getMyShelterLocation();

  /// Create or update shelter location
  Future<void> upsertShelterLocation({
    required double latitude,
    required double longitude,
    required String address,
  });

  Future<ShelterModel> getShelterById(String id);
}

class ShelterDataSourceImpl implements ShelterDataSource {
  final SupabaseClient supabaseClient;

  ShelterDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ShelterModel>> getNearbyShelters({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    try {
      final response = await supabaseClient.rpc(
        'get_nearby_shelters',
        params: {
          'user_lat': latitude,
          'user_lon': longitude,
          'radius_km': radiusKm,
        },
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => ShelterModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error getting nearby shelters: $e');
    }
  }

  @override
  Future<ShelterModel?> getMyShelterLocation() async {
    try {
      final response = await supabaseClient.rpc('get_my_shelter_location');

      if (response == null || (response as List).isEmpty) {
        return null;
      }

      final data = (response as List).first as Map<String, dynamic>;

      // Get user profile info
      final userId = supabaseClient.auth.currentUser?.id;
      final profileResponse = await supabaseClient
          .from('user_profiles')
          .select('full_name, phone, email, avatar_url')
          .eq('id', userId!)
          .single();

      return ShelterModel.fromJson({
        ...data,
        'shelter_name': profileResponse['full_name'],
        'phone': profileResponse['phone'],
        'email': profileResponse['email'],
        'avatar_url': profileResponse['avatar_url'],
      });
    } catch (e) {
      throw Exception('Error getting my shelter location: $e');
    }
  }

  @override
  Future<void> upsertShelterLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await supabaseClient.from('shelter_locations').upsert({
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'is_active': true,
      });
    } catch (e) {
      throw Exception('Error upserting shelter location: $e');
    }
  }

  @override
  Future<ShelterModel> getShelterById(String id) async {
    try {
      final profile = await supabaseClient
          .from('user_profiles')
          .select()
          .eq('id', id)
          .single();

      final location = await supabaseClient
          .from('shelter_locations')
          .select()
          .eq('user_id', id)
          .maybeSingle();

      return ShelterModel.fromJson({
        'id': location?['id']?.toString() ?? id,
        'user_id': id,
        'shelter_name': profile['full_name'] ?? 'Refugio',
        'latitude': location?['latitude'] ?? 0.0,
        'longitude': location?['longitude'] ?? 0.0,
        'address': location?['address'] ?? '',
        'phone': profile['phone'],
        'email': profile['email'],
        'avatar_url': profile['avatar_url'],
        'is_active': true,
        'distance_km': 0.0,
      });
    } catch (e) {
      throw Exception('Error getting shelter by id: $e');
    }
  }
}
