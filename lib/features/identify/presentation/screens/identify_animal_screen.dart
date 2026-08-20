import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/ai_classification_service.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/custom_bottom_nav.dart';
import '../../../../l10n/l10n.dart';
import '../providers/identify_provider.dart';

class IdentifyAnimalScreen extends ConsumerStatefulWidget {
  const IdentifyAnimalScreen({super.key});

  @override
  ConsumerState<IdentifyAnimalScreen> createState() => _IdentifyAnimalScreenState();
}

class _IdentifyAnimalScreenState extends ConsumerState<IdentifyAnimalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _notesController = TextEditingController();
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Requirement 1, 2, 3, 4: Pick photo from Gallery or Camera, validate & set preview state
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        final isValid = await ref.read(identifyProvider.notifier).selectImage(photo);
        if (!isValid && mounted) {
          final err = ref.read(identifyProvider).error ?? 'Invalid file selected.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: AppColors.emergencyRed),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image selection error: $e'), backgroundColor: AppColors.emergencyRed),
        );
      }
    }
  }

  /// Requirement 5, 6, 9, 12: Process Upload to Supabase & Run Analysis
  Future<void> _startUploadAndAnalysis() async {
    final currentLocale = ref.read(localeProvider);
    final success = await ref.read(identifyProvider.notifier).analyzeAnimal(
          userNotes: _notesController.text.trim(),
          languageCode: currentLocale.languageCode,
        );

    if (success && mounted) {
      context.push('/identify/result');
    } else if (mounted) {
      final err = ref.read(identifyProvider).error ?? 'Analysis failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.emergencyRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final identifyState = ref.watch(identifyProvider);
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Requirement 3: Image Preview Mode if photo selected
            if (identifyState.selectedImageBytes != null || identifyState.selectedImageFile != null) ...[
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 140),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: identifyState.selectedImageBytes != null
                              ? Image.memory(
                                  identifyState.selectedImageBytes!,
                                  height: 240,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(identifyState.selectedImageFile!.path),
                                  height: 240,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Photo Selected: ${identifyState.selectedImageFile?.name ?? "animal_photo.jpg"}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),

                      // User Notes Input
                      TextField(
                        controller: _notesController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Add notes for AI (e.g. Injured leg, found in park)...',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white38),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                              label: const Text('Change Photo', style: TextStyle(color: Colors.white)),
                              onPressed: () => ref.read(identifyProvider.notifier).clearSelectedImage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text('Upload & Analyze AI', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: identifyState.isAnalyzing ? null : _startUploadAndAnalysis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Camera Viewfinder Background Simulation
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 100,
                        color: Colors.white.withOpacity(0.08),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select photo from gallery or capture with camera',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scanning Reticle & Laser Overlay
              Center(
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Positioned(
                            top: _animController.value * 270,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primaryLight,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryLight.withOpacity(0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Top Control Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.4),
                    ),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => context.go('/home'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.primaryLight, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Pashu AI Vision 2.0',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.4),
                    ),
                    icon: Icon(
                      _flashOn ? Icons.flash_on : Icons.flash_off,
                      color: _flashOn ? Colors.amber : Colors.white,
                    ),
                    onPressed: () => setState(() => _flashOn = !_flashOn),
                  ),
                ],
              ),
            ),

            // Model Selection Bar (Auto / Fast ML / Deep Gemini Cloud)
            Positioned(
              bottom: 140,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    _ModelOption(
                      label: 'Hybrid Auto',
                      icon: Icons.bolt,
                      isSelected: identifyState.selectedModel == ModelSource.hybrid,
                      onTap: () => ref.read(identifyProvider.notifier).setModel(ModelSource.hybrid),
                    ),
                    _ModelOption(
                      label: 'Level 1: Fast ML',
                      icon: Icons.memory,
                      isSelected: identifyState.selectedModel == ModelSource.tfliteOnDevice,
                      onTap: () => ref.read(identifyProvider.notifier).setModel(ModelSource.tfliteOnDevice),
                    ),
                    _ModelOption(
                      label: 'Level 2: Gemini Cloud',
                      icon: Icons.cloud_outlined,
                      isSelected: identifyState.selectedModel == ModelSource.geminiVisionCloud,
                      onTap: () => ref.read(identifyProvider.notifier).setModel(ModelSource.geminiVisionCloud),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Control Actions (Gallery & Camera Buttons)
            if (identifyState.selectedImageBytes == null && identifyState.selectedImageFile == null)
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Requirement 1: Gallery Upload
                    IconButton(
                      iconSize: 28,
                      tooltip: 'Select Image from Gallery',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white24,
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
                      onPressed: identifyState.isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                    ),

                    // Requirement 2: Camera Capture Shutter
                    GestureDetector(
                      onTap: identifyState.isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: identifyState.isAnalyzing
                                ? AppColors.emergencyRed
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Voice Search Trigger
                    IconButton(
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white24,
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: const Icon(Icons.mic, color: Colors.white),
                      onPressed: () => context.push('/ai-assistant'),
                    ),
                  ],
                ),
              ),

            // Requirement 5: Loading State Overlay while image is processing / uploading to Supabase
            if (identifyState.isAnalyzing)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                        const SizedBox(height: 16),
                        const Text(
                          'Uploading to Supabase Storage bucket "animal-photos"...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Executing AI Vision Classification...',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}

class _ModelOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModelOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.white70),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
