import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';

class MlClassificationResult {
  final String requiredCategory; // animal_ngo, wildlife_rescue, vet_hospital, shelter, govt_vet_hospital
  final double confidence;
  final bool usedMlModel;

  MlClassificationResult({
    required this.requiredCategory,
    required this.confidence,
    required this.usedMlModel,
  });

  String get categoryDisplayName {
    switch (requiredCategory) {
      case 'wildlife_rescue':
        return 'WildlifeSOS / Wildlife Rescue';
      case 'vet_hospital':
        return 'Veterinary Emergency Hospital';
      case 'shelter':
        return 'Animal Shelter / Adoption Center';
      case 'govt_vet_hospital':
        return 'Government Vet Hospital';
      case 'animal_ngo':
      default:
        return 'Animal Welfare NGO';
    }
  }
}

class NgoMlService {
  /// Classifies animal distress report using Python ML API or clean fallback rules engine
  static Future<MlClassificationResult> classifyDistressReport({
    required String animalType,
    required String problem,
    required String description,
    String location = '',
  }) async {
    // 1. Attempt connection to Python ML Service if endpoint configured
    final mlEndpoint = 'http://localhost:8000/classify-ngo';
    try {
      final response = await http.post(
        Uri.parse(mlEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'animal_type': animalType,
          'problem': problem,
          'description': description,
          'location': location,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MlClassificationResult(
          requiredCategory: data['required_category'] ?? 'animal_ngo',
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.94,
          usedMlModel: data['used_ml_model'] ?? true,
        );
      }
    } catch (e) {
      debugPrint('ML API unreachable or timed out. Falling back to Rule-Based ML Classification Service.');
    }

    // 2. Fallback Classification Logic (Rule-based ML classifier)
    return fallbackClassify(animalType: animalType, problem: problem, description: description);
  }

  static MlClassificationResult fallbackClassify({
    required String animalType,
    required String problem,
    required String description,
  }) {
    final text = '$animalType $problem $description'.toLowerCase();

    if (text.contains('bird') ||
        text.contains('snake') ||
        text.contains('monkey') ||
        text.contains('eagle') ||
        text.contains('wild') ||
        text.contains('owl') ||
        text.contains('reptile') ||
        text.contains('pigeon') ||
        text.contains('turtle')) {
      return MlClassificationResult(
        requiredCategory: 'wildlife_rescue',
        confidence: 0.92,
        usedMlModel: false,
      );
    } else if (text.contains('vaccination') ||
        text.contains('hospital') ||
        text.contains('surgery') ||
        text.contains('clinic') ||
        text.contains('rabies bite') ||
        text.contains('doctor') ||
        text.contains('fever')) {
      return MlClassificationResult(
        requiredCategory: 'vet_hospital',
        confidence: 0.90,
        usedMlModel: false,
      );
    } else if (text.contains('adoption') ||
        text.contains('shelter') ||
        text.contains('abandoned') ||
        text.contains('puppy') ||
        text.contains('kitten') ||
        text.contains('homeless')) {
      return MlClassificationResult(
        requiredCategory: 'shelter',
        confidence: 0.88,
        usedMlModel: false,
      );
    } else {
      return MlClassificationResult(
        requiredCategory: 'animal_ngo',
        confidence: 0.85,
        usedMlModel: false,
      );
    }
  }
}
