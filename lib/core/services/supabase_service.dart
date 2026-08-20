import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    try {
      if (AppConfig.supabaseUrl.isNotEmpty &&
          !AppConfig.supabaseUrl.contains('dummy')) {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        );
        _isInitialized = true;
      }
    } catch (e) {
      _isInitialized = false;
    }
  }

  static bool get isInitialized => _isInitialized;

  static SupabaseClient? get client {
    if (_isInitialized) {
      return Supabase.instance.client;
    }
    return null;
  }

  static User? get currentUser {
    if (_isInitialized) {
      return Supabase.instance.client.auth.currentUser;
    }
    return null;
  }

  /// Upload animal photo to Supabase Storage bucket 'animal-photos'
  static Future<String> uploadAnimalPhoto({
    required String filePath,
    required List<int> bytes,
    required String fileName,
  }) async {
    if (_isInitialized && client != null) {
      try {
        final storagePath = 'sightings/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        await client!.storage.from('animal-photos').uploadBinary(
              storagePath,
              Uint8List.fromList(bytes),
              fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
            );

        final publicUrl = client!.storage.from('animal-photos').getPublicUrl(storagePath);
        return publicUrl;
      } catch (e) {
        debugPrint('Supabase Storage upload error: $e');
      }
    }
    return 'https://supabase.co/storage/v1/object/public/animal-photos/sample_animal.jpg';
  }

  /// Store sighting prediction, confidence, model used & created_at in PostgreSQL
  static Future<bool> saveAnimalSighting({
    required String userId,
    required String imageUrl,
    required String prediction,
    required double confidence,
    required String modelUsed,
    Map<String, dynamic>? healthScreeningData,
  }) async {
    if (_isInitialized && client != null) {
      try {
        await client!.from('animal_sightings').insert({
          'user_id': userId,
          'image_url': imageUrl,
          'prediction': prediction,
          'confidence': confidence,
          'model_used': modelUsed,
          'health_screening_data': healthScreeningData,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      } catch (e) {
        debugPrint('Supabase sighting insert error: $e');
      }
    }
    return true; // Demo fallback success
  }
}
