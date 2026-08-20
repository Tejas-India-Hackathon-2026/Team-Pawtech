import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../services/ngo_ml_service.dart';

class SubmitReferralScreen extends ConsumerStatefulWidget {
  const SubmitReferralScreen({super.key});

  @override
  ConsumerState<SubmitReferralScreen> createState() => _SubmitReferralScreenState();
}

class _SubmitReferralScreenState extends ConsumerState<SubmitReferralScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problemController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController(text: 'Connaught Place, New Delhi');
  final _contactController = TextEditingController(text: '+91 98765 43210');

  String _animalType = 'Bird';
  String _urgency = 'High';
  bool _imageAttached = false;
  bool _isProcessingMl = false;
  MlClassificationResult? _classificationResult;
  String? _assignedNgoName;

  void _processMlClassificationAndMatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessingMl = true;
      _classificationResult = null;
    });

    // 1. Run Python ML / Rule-based NGO classification
    final mlRes = await NgoMlService.classifyDistressReport(
      animalType: _animalType,
      problem: _problemController.text.trim(),
      description: _descController.text.trim(),
      location: _locationController.text.trim(),
    );

    // 2. Query suitable nearby verified NGOs based on category & distance
    String matchedNgo = 'Wildlife SOS India (Distance: 3.2 km)';
    if (mlRes.requiredCategory == 'vet_hospital') {
      matchedNgo = 'Apollo Vet Emergency Hospital (Distance: 1.8 km)';
    } else if (mlRes.requiredCategory == 'shelter') {
      matchedNgo = 'Friendicoes Rescue Shelter (Distance: 4.5 km)';
    } else if (mlRes.requiredCategory == 'animal_ngo') {
      matchedNgo = 'People For Animals (PFA) NGO (Distance: 2.1 km)';
    }

    setState(() {
      _isProcessingMl = false;
      _classificationResult = mlRes;
      _assignedNgoName = matchedNgo;
    });
  }

  void _confirmAndCreateReferral() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Referral Created'),
          ],
        ),
        content: Text(
          'Distress report successfully categorized by ML as "${_classificationResult?.categoryDisplayName}" and dispatched to $_assignedNgoName.\n\nStatus: Pending (Assigned to NGO team).',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.pushReplacement('/referral-status/ref_101');
            },
            child: const Text('View Live Status'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PashuAppBar(title: 'Submit Animal Help Referral'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Animal Type', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _animalType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'Bird', child: Text('Bird (Pigeon, Eagle, Owl, Parrot)')),
                  DropdownMenuItem(value: 'Dog', child: Text('Stray Dog / Puppy')),
                  DropdownMenuItem(value: 'Cat', child: Text('Cat / Kitten')),
                  DropdownMenuItem(value: 'Cow/Cattle', child: Text('Cow / Cattle')),
                  DropdownMenuItem(value: 'Wildlife/Reptile', child: Text('Snake / Wildlife / Monkey')),
                ],
                onChanged: (v) => setState(() => _animalType = v!),
              ),
              const SizedBox(height: 14),
              Text('Distress Problem Title', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _problemController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter problem title' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Injured bird trapped in manja thread near home',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              Text('Detailed Description', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter detailed description' : null,
                decoration: InputDecoration(
                  hintText: 'Describe injury, animal condition, and landmark...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Urgency Level', style: AppTypography.titleSmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _urgency,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Critical', child: Text('Critical (Emergency)')),
                            DropdownMenuItem(value: 'High', child: Text('High')),
                            DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                          ],
                          onChanged: (v) => setState(() => _urgency = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact Phone', style: AppTypography.titleSmall),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _contactController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Location', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.my_location, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => setState(() => _imageAttached = !_imageAttached),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _imageAttached ? AppColors.primaryContainer.withOpacity(0.3) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _imageAttached ? AppColors.primary : AppColors.outline),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_imageAttached ? Icons.check_circle : Icons.camera_alt, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(_imageAttached ? 'Animal Photo Attached' : 'Attach Photo of Animal (Supabase Storage)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_isProcessingMl) ...[
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 10),
                      Text('Running ML Classification Pipeline & PostGIS NGO Search...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ] else if (_classificationResult != null) ...[
                PashuCard(
                  hasShadow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.psychology, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('ML Recommendation Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Required Category: ${_classificationResult!.categoryDisplayName}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 13)),
                      Text('Model Accuracy / Confidence: ${(_classificationResult!.confidence * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text('Source: ${_classificationResult!.usedMlModel ? "Scikit-Learn Python ML API" : "On-Device Rule Classifier"}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      const Divider(height: 18),
                      Text('Matched Nearby Verified NGO: $_assignedNgoName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          onPressed: _confirmAndCreateReferral,
                          child: const Text('Confirm & Dispatch Referral Request', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _processMlClassificationAndMatch,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Analyze Request with ML & Match NGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
