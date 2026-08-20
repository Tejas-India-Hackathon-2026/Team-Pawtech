import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/pashu_text_field.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../models/emergency_report.dart';
import '../providers/help_provider.dart';

class ReportEmergencyScreen extends ConsumerStatefulWidget {
  const ReportEmergencyScreen({super.key});

  @override
  ConsumerState<ReportEmergencyScreen> createState() =>
      _ReportEmergencyScreenState();
}

class _ReportEmergencyScreenState extends ConsumerState<ReportEmergencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalTypeController = TextEditingController();
  final _conditionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  EmergencySeverity _severity = EmergencySeverity.critical;
  String? _selectedImagePath;
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user?.phone != null) {
      _phoneController.text = user!.phone!;
    }
    _fetchGPSLocation();
  }

  Future<void> _fetchGPSLocation() async {
    print('[ReportEmergencyScreen] Fetching accurate location...');
    setState(() => _isFetchingLocation = true);
    try {
      Position? position = await LocationService.getAccurateLocation();
      if (position != null) {
        print('================ [GPS FETCH SUCCESS] ================');
        print('Fetched Position Latitude:  ${position.latitude}');
        print('Fetched Position Longitude: ${position.longitude}');
        print('====================================================');

        _latitude = position.latitude;
        _longitude = position.longitude;

        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final addressParts = [
              place.name,
              place.street,
              place.subLocality,
              place.locality,
              place.postalCode,
              place.country,
            ].where((p) => p != null && p.isNotEmpty).toSet().join(', ');

            _addressController.text = addressParts.isNotEmpty
                ? addressParts
                : '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
          } else {
            _addressController.text = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
          }
        } catch (_) {
          _addressController.text = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        }
      }
    } catch (e) {
      _addressController.clear();
      _latitude = null;
      _longitude = null;
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.emergencyRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  @override
  void dispose() {
    _animalTypeController.dispose();
    _conditionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    try {
      final img = await picker.pickImage(source: ImageSource.camera);
      if (img != null) {
        setState(() => _selectedImagePath = img.path);
      }
    } catch (_) {}
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final report = EmergencyReport(
        id: const Uuid().v4(),
        animalType: _animalTypeController.text.trim(),
        conditionDescription: _conditionController.text.trim(),
        severity: _severity,
        address: _addressController.text.trim(),
        latitude: _latitude ?? 0.0,
        longitude: _longitude ?? 0.0,
        photoUrl: _selectedImagePath,
        reporterPhone: _phoneController.text.trim(),
      );

      await ref.read(helpProvider.notifier).submitEmergencyReport(report);
      setState(() => _isSubmitting = false);

      if (mounted) {
        final gpsStr = (_latitude != null && _longitude != null)
            ? '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
            : 'Acquiring GPS...';
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                Text('SOS Broadcasted!', style: AppTypography.titleMedium),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your emergency rescue report for ${_animalTypeController.text.trim()} (GPS: $gpsStr) has been saved and dispatched to nearby rescue units.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.support_agent, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Keep the animal in shade and stay nearby if safe.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text('Back to Dashboard', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Animal in Distress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingScreen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Alert Warning
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRedContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.emergencyRed),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your location and details will be shared with verified NGOs immediately.',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF991B1B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Severity Level Selection
                Text('Urgency Severity Level', style: AppTypography.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SeverityOption(
                      title: 'Critical',
                      subtitle: 'Severe/Bleeding',
                      color: AppColors.emergencyRed,
                      isSelected: _severity == EmergencySeverity.critical,
                      onTap: () => setState(() => _severity = EmergencySeverity.critical),
                    ),
                    const SizedBox(width: 8),
                    _SeverityOption(
                      title: 'Moderate',
                      subtitle: 'Injured/Sick',
                      color: AppColors.warningAmber,
                      isSelected: _severity == EmergencySeverity.moderate,
                      onTap: () => setState(() => _severity = EmergencySeverity.moderate),
                    ),
                    const SizedBox(width: 8),
                    _SeverityOption(
                      title: 'Minor',
                      subtitle: 'Inspection',
                      color: AppColors.primary,
                      isSelected: _severity == EmergencySeverity.minor,
                      onTap: () => setState(() => _severity = EmergencySeverity.minor),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Photo Upload Box
                Text('Photo of Animal / Injury', style: AppTypography.labelLarge),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    ),
                    child: _selectedImagePath != null
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.image, size: 48, color: AppColors.primary),
                              Positioned(
                                bottom: 8,
                                child: Text('Photo Attached (Tap to change)',
                                    style: AppTypography.labelSmall),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt, size: 32, color: AppColors.primary),
                              const SizedBox(height: 6),
                              Text('Tap to Capture or Upload Photo',
                                  style: AppTypography.labelLarge.copyWith(fontSize: 13)),
                              Text('Helps rescue team prepare medical equipment',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                PashuTextField(
                  label: 'Animal Type & Details',
                  hint: 'e.g. Stray puppy, Injured cow, Bird with broken wing',
                  controller: _animalTypeController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter the animal type' : null,
                ),
                const SizedBox(height: 16),

                PashuTextField(
                  label: 'Condition / Visible Injuries',
                  hint: 'Describe visible cuts, limping, fever, or behavior...',
                  controller: _conditionController,
                  maxLines: 3,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please describe the visible injuries or condition' : null,
                ),
                const SizedBox(height: 16),

                PashuTextField(
                  label: 'Exact Location & Landmarks',
                  hint: 'Street, landmark, GPS reference',
                  controller: _addressController,
                  prefixIcon: IconButton(
                    tooltip: 'Fetch Accurate GPS Location',
                    icon: _isFetchingLocation
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : const Icon(Icons.my_location, color: AppColors.primary),
                    onPressed: _fetchGPSLocation,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please specify exact location or fetch GPS position' : null,
                ),
                const SizedBox(height: 16),

                PashuTextField(
                  label: 'Your Contact Phone (for NGO coordinator)',
                  hint: '+91 98765 43210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (val) => val == null || val.isEmpty ? 'Enter contact phone' : null,
                ),
                const SizedBox(height: 28),

                PashuButton(
                  text: 'Broadcast Emergency SOS',
                  icon: Icons.emergency,
                  variant: PashuButtonVariant.emergency,
                  isLoading: _isSubmitting,
                  onPressed: _submitReport,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeverityOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeverityOption({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
