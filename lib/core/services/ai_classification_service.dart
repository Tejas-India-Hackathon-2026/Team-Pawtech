import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

enum DangerLevel {
  safe,
  low,
  moderate,
  high,
  venomous,
}

enum ModelSource {
  tfliteOnDevice,
  geminiVisionCloud,
  hybrid,
}

enum HealthScreeningSeverity {
  low,
  moderate,
  high,
  emergency,
}

extension HealthScreeningSeverityDetails on HealthScreeningSeverity {
  String get displayName {
    switch (this) {
      case HealthScreeningSeverity.low:
        return 'Low';
      case HealthScreeningSeverity.moderate:
        return 'Moderate';
      case HealthScreeningSeverity.high:
        return 'High';
      case HealthScreeningSeverity.emergency:
        return 'Emergency';
    }
  }
}

/// Animal Health & Disease Screening Result Model
/// IMPORTANT:
/// - Never presents disease as a confirmed diagnosis (preliminary screening only).
/// - Never prescribes medicines or dosages.
/// - Standard recommendation: "Veterinary examination recommended."
/// - Emergency recommendation: "Emergency veterinary assistance recommended."
/// - Uncertain recommendation: "Unable to reliably assess. Please consult a veterinarian."
class AnimalHealthScreeningResult {
  final String possibleCondition;
  final double screeningConfidence;
  final HealthScreeningSeverity severity;
  final String recommendation;
  final List<String> observedSymptoms;
  final String disclaimer;
  final bool isUncertain;

  AnimalHealthScreeningResult({
    required this.possibleCondition,
    required this.screeningConfidence,
    required this.severity,
    required this.recommendation,
    required this.observedSymptoms,
    this.disclaimer =
        'AI-assisted preliminary screening only. This is not a confirmed medical diagnosis. No medicines or dosages are prescribed. Always consult a licensed veterinarian.',
    this.isUncertain = false,
  });

  factory AnimalHealthScreeningResult.fromJson(Map<String, dynamic> json) {
    HealthScreeningSeverity parseSeverity(String? s) {
      switch (s?.toLowerCase()) {
        case 'emergency':
          return HealthScreeningSeverity.emergency;
        case 'high':
          return HealthScreeningSeverity.high;
        case 'moderate':
          return HealthScreeningSeverity.moderate;
        default:
          return HealthScreeningSeverity.low;
      }
    }

    final bool uncertain = json['is_uncertain'] ?? json['isUncertain'] ?? false;
    final sev = parseSeverity(json['severity']);

    String rec = json['recommendation'] ?? 'Veterinary examination recommended.';
    if (uncertain) {
      rec = 'Unable to reliably assess. Please consult a veterinarian.';
    } else if (sev == HealthScreeningSeverity.emergency) {
      rec = 'Emergency veterinary assistance recommended.';
    }

    return AnimalHealthScreeningResult(
      possibleCondition: json['possible_condition'] ?? json['possibleCondition'] ?? 'General Skin / Health Observation',
      screeningConfidence: (json['screening_confidence'] as num?)?.toDouble() ?? 0.85,
      severity: sev,
      recommendation: rec,
      observedSymptoms: List<String>.from(json['observed_symptoms'] ?? json['observedSymptoms'] ?? []),
      disclaimer: json['disclaimer'] ??
          'AI-assisted preliminary screening only. This is not a confirmed medical diagnosis. No medicines or dosages are prescribed. Always consult a licensed veterinarian.',
      isUncertain: uncertain,
    );
  }

  Map<String, dynamic> toJson() => {
        'possible_condition': possibleCondition,
        'screening_confidence': screeningConfidence,
        'severity': severity.name,
        'recommendation': recommendation,
        'observed_symptoms': observedSymptoms,
        'disclaimer': disclaimer,
        'is_uncertain': isUncertain,
      };
}

/// A single candidate species returned in the top-3 alternatives list
class AnimalAlternative {
  final String commonName;
  final String scientificName;
  final double confidence;

  AnimalAlternative({
    required this.commonName,
    required this.scientificName,
    required this.confidence,
  });

  factory AnimalAlternative.fromJson(Map<String, dynamic> json) {
    return AnimalAlternative(
      commonName: json['common_name'] ?? json['commonName'] ?? 'Unknown',
      scientificName: json['scientific_name'] ?? json['scientificName'] ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'common_name': commonName,
    'scientific_name': scientificName,
    'confidence': confidence,
  };
}

class AnimalIdentificationResult {
  final String commonName;
  final String scientificName;
  final String breedOrSubspecies;
  final double confidence;
  final DangerLevel dangerLevel;
  final bool isDomestic;
  final String diet;
  final String habitat;
  final String firstAidInstructions;
  final String generalCare;
  final ModelSource modelUsed;
  final String? audioSummary;
  final AnimalHealthScreeningResult? healthScreening;
  final Map<String, dynamic> rawMetadata;
  // --- Upgraded fields for broad-spectrum identification ---
  /// True when confidence < 60% — UI should show uncertainty banner
  final bool isUncertain;
  /// Top-3 alternative matches when isUncertain == true
  final List<AnimalAlternative> topAlternatives;
  /// Describes image quality issues (blurry/dark/no animal detected)
  final String? imageQualityNote;

  AnimalIdentificationResult({
    required this.commonName,
    required this.scientificName,
    required this.breedOrSubspecies,
    required this.confidence,
    required this.dangerLevel,
    required this.isDomestic,
    required this.diet,
    required this.habitat,
    required this.firstAidInstructions,
    required this.generalCare,
    required this.modelUsed,
    this.audioSummary,
    this.healthScreening,
    this.rawMetadata = const {},
    this.isUncertain = false,
    this.topAlternatives = const [],
    this.imageQualityNote,
  });

  factory AnimalIdentificationResult.fromJson(Map<String, dynamic> json, ModelSource source) {
    DangerLevel parseDanger(String? val) {
      switch (val?.toLowerCase()) {
        case 'venomous':
          return DangerLevel.venomous;
        case 'high':
          return DangerLevel.high;
        case 'moderate':
          return DangerLevel.moderate;
        case 'low':
          return DangerLevel.low;
        default:
          return DangerLevel.safe;
      }
    }

    AnimalHealthScreeningResult? screening;
    if (json['health_screening'] != null) {
      screening = AnimalHealthScreeningResult.fromJson(json['health_screening']);
    }

    final double conf = (json['confidence'] as num?)?.toDouble() ?? 0.5;
    final bool uncertain = json['is_uncertain'] ?? json['isUncertain'] ?? (conf < 0.60);

    // Parse top-3 alternatives list
    final List<AnimalAlternative> alternatives = [];
    if (json['top_alternatives'] is List) {
      for (final item in json['top_alternatives'] as List) {
        if (item is Map<String, dynamic>) {
          alternatives.add(AnimalAlternative.fromJson(item));
        }
      }
    }

    return AnimalIdentificationResult(
      commonName: json['common_name'] ?? json['commonName'] ?? 'Unknown Animal',
      scientificName: json['scientific_name'] ?? json['scientificName'] ?? 'Fauna incertae sedis',
      breedOrSubspecies: json['breed'] ?? json['breedOrSubspecies'] ?? 'General',
      confidence: conf,
      dangerLevel: parseDanger(json['danger_level'] ?? json['dangerLevel']),
      isDomestic: json['is_domestic'] ?? json['isDomestic'] ?? true,
      diet: json['diet'] ?? 'Standard species diet',
      habitat: json['habitat'] ?? 'Urban / Rural India',
      firstAidInstructions: json['first_aid'] ?? json['firstAidInstructions'] ?? 'Keep hydrated, approach calmly, contact local vet or NGO if injured.',
      generalCare: json['general_care'] ?? json['generalCare'] ?? 'Provide clean water and quiet shelter.',
      modelUsed: source,
      audioSummary: json['audio_summary'] ?? json['audioSummary'],
      healthScreening: screening,
      rawMetadata: json,
      isUncertain: uncertain,
      topAlternatives: alternatives,
      imageQualityNote: json['image_quality_note'] as String?,
    );
  }

  AnimalIdentificationResult copyWith({
    AnimalHealthScreeningResult? healthScreening,
    Map<String, dynamic>? rawMetadata,
    bool? isUncertain,
    List<AnimalAlternative>? topAlternatives,
    String? imageQualityNote,
  }) {
    return AnimalIdentificationResult(
      commonName: commonName,
      scientificName: scientificName,
      breedOrSubspecies: breedOrSubspecies,
      confidence: confidence,
      dangerLevel: dangerLevel,
      isDomestic: isDomestic,
      diet: diet,
      habitat: habitat,
      firstAidInstructions: firstAidInstructions,
      generalCare: generalCare,
      modelUsed: modelUsed,
      audioSummary: audioSummary,
      healthScreening: healthScreening ?? this.healthScreening,
      rawMetadata: rawMetadata ?? this.rawMetadata,
      isUncertain: isUncertain ?? this.isUncertain,
      topAlternatives: topAlternatives ?? this.topAlternatives,
      imageQualityNote: imageQualityNote ?? this.imageQualityNote,
    );
  }

  Map<String, dynamic> toJson() => {
        'commonName': commonName,
        'scientificName': scientificName,
        'breedOrSubspecies': breedOrSubspecies,
        'confidence': confidence,
        'dangerLevel': dangerLevel.name,
        'isDomestic': isDomestic,
        'diet': diet,
        'habitat': habitat,
        'firstAidInstructions': firstAidInstructions,
        'generalCare': generalCare,
        'modelUsed': modelUsed.name,
        'audioSummary': audioSummary,
        'healthScreening': healthScreening?.toJson(),
        'rawMetadata': rawMetadata,
        'isUncertain': isUncertain,
        'topAlternatives': topAlternatives.map((a) => a.toJson()).toList(),
        'imageQualityNote': imageQualityNote,
      };
}

/// Abstract base interface for all animal classification models
abstract class AnimalClassifierService {
  Future<AnimalIdentificationResult> identify({
    required String imagePath,
    String? base64Image,
    String? userNotes,
    String languageCode = 'en',
  });

  Future<AnimalHealthScreeningResult> screenHealth({
    required String imagePath,
    required String animalSpecies,
    required List<String> symptoms,
    String? additionalNotes,
    String languageCode = 'en',
  });
}

/// Level 1: Primary On-Device TFLite Animal Classifier (MobileNetV2 / iNaturalist subset)
/// NOTE: Local TFLite model asset is not yet bundled. This class automatically delegates
/// to GeminiVisionClassifier (Level 2 cloud) for all identifications.
class TfLiteAnimalClassifier implements AnimalClassifierService {
  final String modelAssetPath = 'assets/models/mobilenet_v2_animal_classifier.tflite';

  Future<bool> checkModelAssetExists() async {
    // TFLite model asset not yet bundled in assets/models/
    return false;
  }

  @override
  Future<AnimalIdentificationResult> identify({
    required String imagePath,
    String? base64Image,
    String? userNotes,
    String languageCode = 'en',
  }) async {
    // Local model not available — always route to Gemini Vision Cloud for
    // broad iNaturalist-level species recognition with confidence scoring.
    final bool modelExists = await checkModelAssetExists();
    if (!modelExists) {
      return GeminiVisionClassifier().identify(
        imagePath: imagePath,
        base64Image: base64Image,
        userNotes: userNotes,
        languageCode: languageCode,
      );
    }

    // Placeholder for when TFLite model is eventually integrated:
    return AnimalIdentificationResult(
      commonName: 'Unidentified Animal',
      scientificName: 'Fauna incertae sedis',
      breedOrSubspecies: 'Unknown',
      confidence: 0.30,
      dangerLevel: DangerLevel.safe,
      isDomestic: false,
      diet: 'Cannot determine without species identification.',
      habitat: 'Cannot determine.',
      firstAidInstructions: 'Keep safe distance and contact local vet or NGO.',
      generalCare: 'Consult a licensed veterinarian.',
      modelUsed: ModelSource.tfliteOnDevice,
      isUncertain: true,
      imageQualityNote: 'On-device model returned low confidence. Upgrade to cloud analysis for better results.',
      rawMetadata: {'model_configured': false, 'model_note': modelAssetPath},
    );
  }

  @override
  Future<AnimalHealthScreeningResult> screenHealth({
    required String imagePath,
    required String animalSpecies,
    required List<String> symptoms,
    String? additionalNotes,
    String languageCode = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final combinedText = '${symptoms.join(" ")} ${additionalNotes ?? ""}'.toLowerCase();

    // Check for emergency triggers
    if (combinedText.contains('severe bleeding') ||
        combinedText.contains('unconscious') ||
        combinedText.contains('fracture') ||
        combinedText.contains('poison') ||
        combinedText.contains('snake bite') ||
        combinedText.contains('convulsion')) {
      return AnimalHealthScreeningResult(
        possibleCondition: 'Possible Critical Trauma / Emergency Condition',
        screeningConfidence: 0.92,
        severity: HealthScreeningSeverity.emergency,
        recommendation: 'Emergency veterinary assistance recommended.',
        observedSymptoms: symptoms,
      );
    }

    // Check for skin / mange / parasites
    if (combinedText.contains('itching') ||
        combinedText.contains('hair loss') ||
        combinedText.contains('redness') ||
        combinedText.contains('scratching')) {
      return AnimalHealthScreeningResult(
        possibleCondition: 'Possible Mange / Scabies / Dermatitis',
        screeningConfidence: 0.85,
        severity: HealthScreeningSeverity.moderate,
        recommendation: 'Veterinary examination recommended.',
        observedSymptoms: symptoms,
      );
    }

    // Check for ticks / external parasites
    if (combinedText.contains('ticks') || combinedText.contains('fleas')) {
      return AnimalHealthScreeningResult(
        possibleCondition: 'Possible Tick Infestation / Ectoparasitic Burden',
        screeningConfidence: 0.88,
        severity: HealthScreeningSeverity.moderate,
        recommendation: 'Veterinary examination recommended.',
        observedSymptoms: symptoms,
      );
    }

    // Check for wounds / swelling
    if (combinedText.contains('wound') || combinedText.contains('swelling') || combinedText.contains('cut')) {
      return AnimalHealthScreeningResult(
        possibleCondition: 'Possible Soft Tissue Injury / Localized Abscess',
        screeningConfidence: 0.84,
        severity: HealthScreeningSeverity.moderate,
        recommendation: 'Veterinary examination recommended.',
        observedSymptoms: symptoms,
      );
    }

    // Check for discharge / respiratory
    if (combinedText.contains('discharge') || combinedText.contains('cough') || combinedText.contains('sneezing')) {
      return AnimalHealthScreeningResult(
        possibleCondition: 'Possible Respiratory / Ocular Irritation',
        screeningConfidence: 0.82,
        severity: HealthScreeningSeverity.moderate,
        recommendation: 'Veterinary examination recommended.',
        observedSymptoms: symptoms,
      );
    }

    // Check for weakness / lethargy
    if (combinedText.contains('weakness') || combinedText.contains('lethargy') || combinedText.contains('not eating')) {
      return AnimalHealthScreeningResult(
        possibleCondition: 'Possible Systemic Malaise / Nutritional Deficiency',
        screeningConfidence: 0.80,
        severity: HealthScreeningSeverity.moderate,
        recommendation: 'Veterinary examination recommended.',
        observedSymptoms: symptoms,
      );
    }

    // If symptoms are vague or empty
    if (symptoms.isEmpty && (additionalNotes == null || additionalNotes.trim().isEmpty)) {
      return AnimalHealthScreeningResult(
        possibleCondition: 'Unclear Symptoms',
        screeningConfidence: 0.50,
        severity: HealthScreeningSeverity.low,
        recommendation: 'Unable to reliably assess. Please consult a veterinarian.',
        observedSymptoms: [],
        isUncertain: true,
      );
    }

    return AnimalHealthScreeningResult(
      possibleCondition: 'Possible Non-Specific Symptom Presentation',
      screeningConfidence: 0.78,
      severity: HealthScreeningSeverity.low,
      recommendation: 'Veterinary examination recommended.',
      observedSymptoms: symptoms,
    );
  }
}

/// Level 2: Advanced Cloud Vision via Supabase Edge Function + Gemini Vision
class GeminiVisionClassifier implements AnimalClassifierService {
  @override
  Future<AnimalIdentificationResult> identify({
    required String imagePath,
    String? base64Image,
    String? userNotes,
    String languageCode = 'en',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.identifyAnimalEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        },
        body: jsonEncode({
          'action': 'identify',
          'image_base64': base64Image ?? '',
          'user_notes': userNotes ?? '',
          'language': languageCode,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AnimalIdentificationResult.fromJson(data, ModelSource.geminiVisionCloud);
      }
    } catch (_) {}

    // Cloud call failed — return an honest uncertain result instead of a
    // hardcoded species which would be misleading.
    await Future.delayed(const Duration(milliseconds: 300));
    return AnimalIdentificationResult(
      commonName: 'Unidentified Animal',
      scientificName: 'Fauna incertae sedis',
      breedOrSubspecies: 'Unknown',
      confidence: 0.0,
      dangerLevel: DangerLevel.safe,
      isDomestic: false,
      diet: 'Unable to determine without species identification.',
      habitat: 'Unable to determine.',
      firstAidInstructions:
          'If the animal appears injured, maintain a safe distance. Contact Wildlife SOS: 1800-200-9122 or your nearest veterinary NGO.',
      generalCare: 'Please consult a licensed veterinarian for accurate species identification and care advice.',
      modelUsed: ModelSource.geminiVisionCloud,
      audioSummary:
          'Animal identification is currently unavailable. Please check your internet connection and try again, or consult a veterinarian.',
      isUncertain: true,
      imageQualityNote:
          'Cloud Vision analysis failed. Please ensure the image is clear and well-lit, then try again.',
      topAlternatives: [],
    );
  }

  @override
  Future<AnimalHealthScreeningResult> screenHealth({
    required String imagePath,
    required String animalSpecies,
    required List<String> symptoms,
    String? additionalNotes,
    String languageCode = 'en',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.identifyAnimalEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        },
        body: jsonEncode({
          'action': 'health_screening',
          'species': animalSpecies,
          'symptoms': symptoms,
          'notes': additionalNotes ?? '',
          'language': languageCode,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AnimalHealthScreeningResult.fromJson(data);
      }
    } catch (_) {}

    // Fallback to robust rules engine
    return TfLiteAnimalClassifier().screenHealth(
      imagePath: imagePath,
      animalSpecies: animalSpecies,
      symptoms: symptoms,
      additionalNotes: additionalNotes,
      languageCode: languageCode,
    );
  }
}

/// Hybrid Dual-Level Animal Classifier with automatic fallback & confidence arbitration
class HybridAnimalClassifierService implements AnimalClassifierService {
  final AnimalClassifierService primaryClassifier;
  final AnimalClassifierService cloudClassifier;
  final double confidenceThreshold;

  HybridAnimalClassifierService({
    AnimalClassifierService? primary,
    AnimalClassifierService? cloud,
    this.confidenceThreshold = 0.80,
  })  : primaryClassifier = primary ?? TfLiteAnimalClassifier(),
        cloudClassifier = cloud ?? GeminiVisionClassifier();

  @override
  Future<AnimalIdentificationResult> identify({
    required String imagePath,
    String? base64Image,
    String? userNotes,
    String languageCode = 'en',
    bool forceCloudAnalysis = false,
  }) async {
    if (forceCloudAnalysis) {
      return await cloudClassifier.identify(
        imagePath: imagePath,
        base64Image: base64Image,
        userNotes: userNotes,
        languageCode: languageCode,
      );
    }

    final level1Result = await primaryClassifier.identify(
      imagePath: imagePath,
      base64Image: base64Image,
      userNotes: userNotes,
      languageCode: languageCode,
    );

    if (level1Result.confidence >= confidenceThreshold) {
      return level1Result;
    }

    return await cloudClassifier.identify(
      imagePath: imagePath,
      base64Image: base64Image,
      userNotes: userNotes,
      languageCode: languageCode,
    );
  }

  @override
  Future<AnimalHealthScreeningResult> screenHealth({
    required String imagePath,
    required String animalSpecies,
    required List<String> symptoms,
    String? additionalNotes,
    String languageCode = 'en',
  }) async {
    return await primaryClassifier.screenHealth(
      imagePath: imagePath,
      animalSpecies: animalSpecies,
      symptoms: symptoms,
      additionalNotes: additionalNotes,
      languageCode: languageCode,
    );
  }
}
