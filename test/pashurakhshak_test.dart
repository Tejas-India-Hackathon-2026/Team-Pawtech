import 'package:flutter_test/flutter_test.dart';
import 'package:pashurakhshak/core/services/ai_classification_service.dart';
import 'package:pashurakhshak/core/services/payment_service.dart';
import 'package:pashurakhshak/features/auth/models/user_profile.dart';
import 'package:pashurakhshak/features/help/models/emergency_report.dart';
import 'package:pashurakhshak/features/help/models/rescue_organization.dart';
import 'package:pashurakhshak/l10n/l10n.dart';

void main() {
  group('PashuRakhshak AI & Health Screening Tests', () {
    test('AnimalIdentificationResult should parse valid JSON correctly', () {
      final json = {
        'common_name': 'Indian Peacock',
        'scientific_name': 'Pavo cristatus',
        'breed': 'Aves / Phasianidae',
        'confidence': 0.98,
        'danger_level': 'safe',
        'is_domestic': false,
        'diet': 'Grains, berries, seeds, insects, small snakes',
        'habitat': 'Open forests and agricultural fields in India',
        'first_aid': 'National bird of India. Protected under Schedule I.',
        'general_care': 'Strict legal protection. Provide safe open sanctuary.',
      };

      final result = AnimalIdentificationResult.fromJson(
        json,
        ModelSource.geminiVisionCloud,
      );

      expect(result.commonName, 'Indian Peacock');
      expect(result.scientificName, 'Pavo cristatus');
      expect(result.confidence, 0.98);
      expect(result.dangerLevel, DangerLevel.safe);
      expect(result.isDomestic, false);
      expect(result.modelUsed, ModelSource.geminiVisionCloud);
    });

    test('AnimalHealthScreeningResult should enforce safety rules & disclaimers', () {
      final json = {
        'possible_condition': 'Possible Mange / Scabies',
        'screening_confidence': 0.85,
        'severity': 'moderate',
        'recommendation': 'Veterinary examination recommended.',
        'observed_symptoms': ['itching', 'redness', 'hair loss'],
      };

      final healthResult = AnimalHealthScreeningResult.fromJson(json);

      expect(healthResult.possibleCondition, contains('Possible'));
      expect(healthResult.screeningConfidence, 0.85);
      expect(healthResult.severity, HealthScreeningSeverity.moderate);
      expect(healthResult.recommendation, 'Veterinary examination recommended.');
      expect(healthResult.disclaimer, contains('not a confirmed medical diagnosis'));
      expect(healthResult.disclaimer, contains('No medicines or dosages are prescribed'));
    });

    test('Emergency severity should trigger emergency recommendation', () () {
      final json = {
        'possible_condition': 'Possible Severe Bleeding Trauma',
        'screening_confidence': 0.94,
        'severity': 'emergency',
        'observed_symptoms': ['wound', 'severe bleeding'],
      };

      final healthResult = AnimalHealthScreeningResult.fromJson(json);

      expect(healthResult.severity, HealthScreeningSeverity.emergency);
      expect(healthResult.recommendation, 'Emergency veterinary assistance recommended.');
    });

    test('Uncertain result should trigger uncertainty fallback recommendation', () () {
      final json = {
        'possible_condition': 'Unclear Symptoms',
        'screening_confidence': 0.40,
        'severity': 'low',
        'is_uncertain': true,
        'observed_symptoms': [],
      };

      final healthResult = AnimalHealthScreeningResult.fromJson(json);

      expect(healthResult.isUncertain, true);
      expect(healthResult.recommendation, 'Unable to reliably assess. Please consult a veterinarian.');
    });

    test('TfLiteAnimalClassifier should screen health using CNN visual + NLP correlation', () async {
      final classifier = TfLiteAnimalClassifier();

      final result = await classifier.screenHealth(
        imagePath: 'sample.jpg',
        animalSpecies: 'Dog',
        symptoms: ['itching', 'hair loss', 'redness'],
      );

      expect(result.possibleCondition, contains('Mange'));
      expect(result.severity, HealthScreeningSeverity.moderate);
      expect(result.recommendation, 'Veterinary examination recommended.');
    });

    test('RescueOrganization should support all required category enums', () {
      expect(OrgCategory.values.length, 7);
      expect(OrgCategory.govtVetHospital.label, 'Govt. Vet Hospital');
      expect(OrgCategory.wildlifeRescue.label, 'Wildlife Rescue');
      expect(OrgCategory.vetClinic.label, 'Veterinary Clinic');
    });

    test('PaymentPlan should have exact INR subscription pricing (₹99 & ₹999)', () {
      expect(PaymentPlan.monthly99.amountInr, 99);
      expect(PaymentPlan.yearly999.amountInr, 999);
    });

    test('AppLanguages should support all 13 required Indian languages', () {
      final requiredCodes = [
        'en', 'hi', 'bho', 'bn', 'ta', 'te', 'mr', 'gu', 'pa', 'kn', 'ml', 'or', 'as'
      ];

      for (final code in requiredCodes) {
        final match = AppLanguages.supportedLocales.any((l) => l.code == code);
        expect(match, true, reason: 'Missing support for locale code $code');
      }

      expect(AppLanguages.get('appName', 'hi'), 'पशुरक्षक');
      expect(AppLanguages.get('appName', 'en'), 'PashuRakhshak');
    });
  });
}
