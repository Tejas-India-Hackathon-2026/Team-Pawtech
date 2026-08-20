import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ai_classification_service.dart';
import '../../../../core/services/supabase_service.dart';

final aiClassifierServiceProvider = Provider<AnimalClassifierService>((ref) {
  return HybridAnimalClassifierService();
});

class IdentifyState {
  final bool isAnalyzing;
  final bool isScreeningHealth;
  final AnimalIdentificationResult? result;
  final AnimalHealthScreeningResult? healthScreeningResult;
  final String? error;
  final ModelSource selectedModel;
  final String? imagePath;
  final XFile? selectedImageFile;
  final Uint8List? selectedImageBytes;
  final String? uploadedStorageUrl;
  final List<String> selectedSymptoms;

  const IdentifyState({
    this.isAnalyzing = false,
    this.isScreeningHealth = false,
    this.result,
    this.healthScreeningResult,
    this.error,
    this.selectedModel = ModelSource.hybrid,
    this.imagePath,
    this.selectedImageFile,
    this.selectedImageBytes,
    this.uploadedStorageUrl,
    this.selectedSymptoms = const [],
  });

  IdentifyState copyWith({
    bool? isAnalyzing,
    bool? isScreeningHealth,
    AnimalIdentificationResult? result,
    AnimalHealthScreeningResult? healthScreeningResult,
    String? error,
    ModelSource? selectedModel,
    String? imagePath,
    XFile? selectedImageFile,
    Uint8List? selectedImageBytes,
    String? uploadedStorageUrl,
    List<String>? selectedSymptoms,
    bool clearHealthScreening = false,
    bool clearImage = false,
  }) {
    return IdentifyState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isScreeningHealth: isScreeningHealth ?? this.isScreeningHealth,
      result: result ?? this.result,
      healthScreeningResult: clearHealthScreening
          ? null
          : (healthScreeningResult ?? this.healthScreeningResult),
      error: error,
      selectedModel: selectedModel ?? this.selectedModel,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      selectedImageFile: clearImage ? null : (selectedImageFile ?? this.selectedImageFile),
      selectedImageBytes: clearImage ? null : (selectedImageBytes ?? this.selectedImageBytes),
      uploadedStorageUrl: uploadedStorageUrl ?? this.uploadedStorageUrl,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
    );
  }
}

class IdentifyNotifier extends StateNotifier<IdentifyState> {
  final AnimalClassifierService _classifier;

  IdentifyNotifier(this._classifier) : super(const IdentifyState());

  void setModel(ModelSource model) {
    state = state.copyWith(selectedModel: model);
  }

  void toggleSymptom(String symptom) {
    final list = List<String>.from(state.selectedSymptoms);
    if (list.contains(symptom)) {
      list.remove(symptom);
    } else {
      list.add(symptom);
    }
    state = state.copyWith(selectedSymptoms: list);
  }

  /// Requirement 3 & 4: Select Image File, Validate Image Format, and Show Immediate Preview
  Future<bool> selectImage(XFile file) async {
    final path = file.path.toLowerCase();
    final name = file.name.toLowerCase();

    // Validate that only image files are accepted
    final isImage = path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.heic') ||
        path.endsWith('.bmp') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp');

    if (!isImage) {
      state = state.copyWith(
        error: 'Invalid file type. Please select a valid image file (JPEG, PNG, WEBP).',
        clearImage: true,
      );
      return false;
    }

    try {
      final bytes = await file.readAsBytes();
      state = state.copyWith(
        selectedImageFile: file,
        selectedImageBytes: bytes,
        imagePath: file.path,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Could not read image file: $e',
        clearImage: true,
      );
      return false;
    }
  }

  void clearSelectedImage() {
    state = state.copyWith(clearImage: true, error: null);
  }

  /// Requirement 5, 6, 8, 9: Process Upload to Supabase Storage and Run AI Identification
  Future<bool> analyzeAnimal({
    String? userNotes,
    String languageCode = 'en',
  }) async {
    final imageFile = state.selectedImageFile;
    final imageBytes = state.selectedImageBytes;
    final path = state.imagePath ?? 'sample_animal.jpg';

    state = state.copyWith(
      isAnalyzing: true,
      error: null,
      clearHealthScreening: true,
      selectedSymptoms: [],
    );

    try {
      // Requirement 9: Upload image to Supabase Storage and get public URL
      String storageUrl = 'https://supabase.co/storage/v1/object/public/animal-photos/sightings/sample.jpg';
      if (imageBytes != null && imageBytes.isNotEmpty) {
        storageUrl = await SupabaseService.uploadAnimalPhoto(
          filePath: path,
          bytes: imageBytes,
          fileName: imageFile?.name ?? 'animal_scan.jpg',
        );
      }

      final bool forceCloud = state.selectedModel == ModelSource.geminiVisionCloud;

      AnimalIdentificationResult res;
      if (_classifier is HybridAnimalClassifierService) {
        res = await (_classifier as HybridAnimalClassifierService).identify(
          imagePath: path,
          userNotes: userNotes,
          languageCode: languageCode,
          forceCloudAnalysis: forceCloud,
        );
      } else {
        res = await _classifier.identify(
          imagePath: path,
          userNotes: userNotes,
          languageCode: languageCode,
        );
      }

      // Save sighting to database
      await SupabaseService.saveAnimalSighting(
        userId: 'current_user',
        imageUrl: storageUrl,
        prediction: res.commonName,
        confidence: res.confidence,
        modelUsed: res.modelUsed.name,
      );

      state = state.copyWith(
        isAnalyzing: false,
        uploadedStorageUrl: storageUrl,
        result: res,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        error: 'Failed to analyze animal photo: $e',
      );
      return false;
    }
  }

  Future<bool> runHealthScreening({
    required List<String> symptoms,
    String? additionalNotes,
    String languageCode = 'en',
  }) async {
    if (state.result == null) return false;

    state = state.copyWith(isScreeningHealth: true, error: null);

    try {
      final healthRes = await _classifier.screenHealth(
        imagePath: state.imagePath ?? 'sample.jpg',
        animalSpecies: state.result!.commonName,
        symptoms: symptoms,
        additionalNotes: additionalNotes,
        languageCode: languageCode,
      );

      state = state.copyWith(
        isScreeningHealth: false,
        healthScreeningResult: healthRes,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isScreeningHealth: false,
        error: 'Health screening error: $e',
      );
      return false;
    }
  }

  void clearResult() {
    state = const IdentifyState();
  }
}

final identifyProvider = StateNotifierProvider<IdentifyNotifier, IdentifyState>((ref) {
  final classifier = ref.watch(aiClassifierServiceProvider);
  return IdentifyNotifier(classifier);
});
