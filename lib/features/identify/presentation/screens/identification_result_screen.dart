import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/ai_classification_service.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/tag_badge.dart';
import '../../../../l10n/l10n.dart';
import '../providers/identify_provider.dart';

class IdentificationResultScreen extends ConsumerStatefulWidget {
  const IdentificationResultScreen({super.key});

  @override
  ConsumerState<IdentificationResultScreen> createState() =>
      _IdentificationResultScreenState();
}

class _IdentificationResultScreenState
    extends ConsumerState<IdentificationResultScreen> {
  bool _isPlayingAudio = false;
  bool _showHealthScreening = false;
  final TextEditingController _symptomNotesController = TextEditingController();
  bool _isListeningVoice = false;

  final List<String> availableSymptoms = [
    'itching',
    'redness',
    'hair loss',
    'wound',
    'swelling',
    'ticks',
    'discharge',
    'weakness',
    'other symptoms',
  ];

  @override
  void dispose() {
    VoiceService().stopSpeaking();
    _symptomNotesController.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String text, String langCode) async {
    if (_isPlayingAudio) {
      await VoiceService().stopSpeaking();
      if (mounted) setState(() => _isPlayingAudio = false);
    } else {
      if (mounted) setState(() => _isPlayingAudio = true);
      await VoiceService().speak(
        text,
        languageCode: '$langCode-IN',
        onComplete: () {
          if (mounted) setState(() => _isPlayingAudio = false);
        },
      );
    }
  }

  Future<void> _toggleVoiceInput(String langCode) async {
    if (_isListeningVoice) {
      await VoiceService().stopListening();
      setState(() => _isListeningVoice = false);
    } else {
      setState(() => _isListeningVoice = true);
      await VoiceService().startListening(
        languageCode: '$langCode-IN',
        onResult: (val) {
          setState(() {
            _symptomNotesController.text = val;
            _isListeningVoice = false;
          });
        },
      );
    }
  }

  Future<void> _runHealthScreening() async {
    final identifyState = ref.read(identifyProvider);
    final currentLocale = ref.read(localeProvider);

    await ref.read(identifyProvider.notifier).runHealthScreening(
          symptoms: identifyState.selectedSymptoms,
          additionalNotes: _symptomNotesController.text.trim(),
          languageCode: currentLocale.languageCode,
        );
  }

  TagVariant _getSeverityTagVariant(HealthScreeningSeverity severity) {
    switch (severity) {
      case HealthScreeningSeverity.low:
        return TagVariant.info;
      case HealthScreeningSeverity.moderate:
        return TagVariant.warning;
      case HealthScreeningSeverity.high:
      case HealthScreeningSeverity.emergency:
        return TagVariant.danger;
    }
  }

  String _getDynamicFirstAidTips(List<String> selectedSymptoms, String userText, String defaultFirstAid) {
    final combined = ('${selectedSymptoms.join(" ")} $userText').toLowerCase().trim();
    if (combined.isEmpty) {
      return defaultFirstAid;
    }

    final List<String> tips = [];
    if (combined.contains('weakness') || combined.contains('lethargy')) {
      tips.add('• Provide quiet rest in a shaded, well-ventilated area.\n• Offer fresh, clean water in a shallow bowl (do not force-feed).\n• Monitor hydration and appetite; seek veterinary evaluation if weakness persists.');
    }
    if (combined.contains('wound') || combined.contains('cut')) {
      tips.add('• Avoid touching or probing deep wounds.\n• Gently clean superficial abrasions with dilute Betadine or saline solution.\n• Cover loosely with clean gauze and seek veterinary care for deep cuts.');
    }
    if (combined.contains('bleed')) {
      tips.add('• Apply gentle, steady pressure directly over bleeding area using clean cotton gauze.\n• Keep the animal calm and restrict movement.\n• Seek urgent veterinary or rescue ambulance help for heavy or continuous bleeding.');
    }
    if (combined.contains('limp')) {
      tips.add('• Restrict movement and discourage jumping or running.\n• Keep in a comfortable, cushioned resting spot.\n• Seek veterinary assessment if limping is severe or does not improve after rest.');
    }
    if (combined.contains('tick') || combined.contains('flea')) {
      tips.add('• Remove ticks gently using fine-tipped tweezers at skin level without twisting or crushing.\n• Clean tick bite site with antiseptic.\n• Consult a vet for tick prevention spot-ons and watch for high fever.');
    }
    if (combined.contains('itching') || combined.contains('redness') || combined.contains('hair loss')) {
      tips.add('• Avoid bathing with harsh shampoos or applying human creams.\n• Keep skin clean and dry.\n• Schedule a vet visit for skin scraping and targeted anti-parasitic treatment.');
    }
    if (combined.contains('swelling')) {
      tips.add('• Apply a cool, damp cloth if tolerated by the animal.\n• Restrict activity and monitor for rapid swelling growth.\n• Consult a veterinarian promptly for painful or expanding swelling.');
    }
    if (combined.contains('discharge') || combined.contains('cough')) {
      tips.add('• Wipe ocular/nasal discharge with clean damp cotton.\n• Keep in a warm, dust-free environment.\n• Seek veterinary checkup for persistent coughing or laboured breathing.');
    }

    if (tips.isEmpty) {
      return defaultFirstAid;
    }

    return tips.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final identifyState = ref.watch(identifyProvider);
    final result = identifyState.result;
    final healthResult = identifyState.healthScreeningResult;
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Identification')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('No scan result found', style: AppTypography.titleMedium),
              const SizedBox(height: 16),
              PashuButton(
                text: 'Scan Again',
                width: 200,
                onPressed: () => context.go('/identify'),
              ),
            ],
          ),
        ),
      );
    }

    TagVariant getDangerVariant(DangerLevel level) {
      switch (level) {
        case DangerLevel.safe:
          return TagVariant.success;
        case DangerLevel.low:
          return TagVariant.info;
        case DangerLevel.moderate:
          return TagVariant.warning;
        case DangerLevel.high:
        case DangerLevel.venomous:
          return TagVariant.danger;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Share Result',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Animal Identification Header Card
              PashuCard(
                padding: const EdgeInsets.all(18),
                backgroundColor: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (identifyState.selectedImageBytes != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          identifyState.selectedImageBytes!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.commonName,
                                style: AppTypography.displayMedium.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                result.scientificName,
                                style: AppTypography.bodySmall.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  TagBadge(
                                    text: '${(result.confidence * 100).toInt()}% Match',
                                    variant: TagVariant.primary,
                                    icon: Icons.verified_outlined,
                                  ),
                                  TagBadge(
                                    text: result.dangerLevel.name.toUpperCase(),
                                    variant: getDangerVariant(result.dangerLevel),
                                    icon: Icons.shield,
                                  ),
                                  TagBadge(
                                    text: result.isDomestic ? 'Domestic' : 'Wild',
                                    variant: TagVariant.neutral,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Requirement 9: Saved Supabase Storage URL
                    if (identifyState.uploadedStorageUrl != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_done, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Saved to Supabase Storage: ${identifyState.uploadedStorageUrl}',
                                style: const TextStyle(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    const Divider(),
                    const SizedBox(height: 8),

                    // Model Badge & Voice narration trigger
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              result.modelUsed == ModelSource.geminiVisionCloud
                                  ? Icons.cloud_done
                                  : Icons.memory,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              result.modelUsed == ModelSource.geminiVisionCloud
                                  ? 'Verified by Gemini Deep Vision'
                                  : 'Identified by Fast On-Device ML',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            final speechText = result.audioSummary ??
                                '${result.commonName}. First Aid: ${result.firstAidInstructions}';
                            _toggleAudio(speechText, lang);
                          },
                          icon: Icon(
                            _isPlayingAudio ? Icons.stop_circle : Icons.volume_up,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            _isPlayingAudio ? 'Stop' : 'Listen',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. CHECK ANIMAL HEALTH (Optional Integrated Step)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0284C7).withOpacity(0.08),
                      const Color(0xFF059669).withOpacity(0.08)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0284C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.health_and_safety,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Health & Disease Screening',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0369A1),
                                  ),
                                ),
                                Text(
                                  'Screen same photo with CNN + symptom NLP',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _showHealthScreening = !_showHealthScreening);
                          },
                          child: Text(
                            _showHealthScreening ? 'Hide' : 'Check Health',
                            style: AppTypography.labelLarge.copyWith(
                              color: const Color(0xFF0284C7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_showHealthScreening) ...[
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),

                      Text(
                        'Select observed symptoms for this ${result.commonName}:',
                        style: AppTypography.labelLarge.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 8),

                      // Symptom Chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: availableSymptoms.map((symptom) {
                          final isSelected =
                              identifyState.selectedSymptoms.contains(symptom);
                          return FilterChip(
                            label: Text(symptom),
                            selected: isSelected,
                            selectedColor: const Color(0xFFBAE6FD),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF0369A1)
                                  : AppColors.textSecondary,
                            ),
                            onSelected: (_) => ref
                                .read(identifyProvider.notifier)
                                .toggleSymptom(symptom),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Text and Voice Symptom Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _symptomNotesController,
                              decoration: InputDecoration(
                                hintText: 'Describe signs (or use mic)...',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: _isListeningVoice
                                  ? AppColors.emergencyRed
                                  : const Color(0xFFE0F2FE),
                            ),
                            icon: Icon(
                              _isListeningVoice ? Icons.mic : Icons.mic_none,
                              color: _isListeningVoice
                                  ? Colors.white
                                  : const Color(0xFF0284C7),
                            ),
                            onPressed: () => _toggleVoiceInput(lang),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      PashuButton(
                        text: 'Analyze Image & Symptoms',
                        icon: Icons.auto_awesome,
                        isLoading: identifyState.isScreeningHealth,
                        onPressed: _runHealthScreening,
                      ),

                      // Health Screening Structured Result Card
                      if (healthResult != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: healthResult.severity == HealthScreeningSeverity.emergency
                                  ? AppColors.emergencyRed
                                  : const Color(0xFFBAE6FD),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Health Screening Assessment',
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  TagBadge(
                                    text: 'Severity: ${healthResult.severity.displayName}',
                                    variant: _getSeverityTagVariant(healthResult.severity),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Animal & ID Match
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Animal Identified:', style: AppTypography.bodySmall),
                                  Text('${result.commonName} (${(result.confidence * 100).toInt()}% Match)',
                                      style: AppTypography.labelLarge.copyWith(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Possible Health Condition (Never confirmed)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Possible Condition:', style: AppTypography.bodySmall),
                                  Expanded(
                                    child: Text(
                                      healthResult.possibleCondition,
                                      textAlign: TextAlign.end,
                                      style: AppTypography.labelLarge.copyWith(
                                        color: const Color(0xFF0369A1),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // AI Screening Confidence
                              if (healthResult.screeningConfidence > 0) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Screening Confidence:', style: AppTypography.bodySmall),
                                    Text('${(healthResult.screeningConfidence * 100).toInt()}%',
                                        style: AppTypography.labelLarge.copyWith(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                              ],
                              const SizedBox(height: 6),
                              const Divider(),
                              const SizedBox(height: 8),

                              // Recommendation Box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: healthResult.severity == HealthScreeningSeverity.emergency
                                      ? const Color(0xFFFEF2F2)
                                      : const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: healthResult.severity == HealthScreeningSeverity.emergency
                                        ? const Color(0xFFFECACA)
                                        : const Color(0xFFBBF7D0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      healthResult.severity == HealthScreeningSeverity.emergency
                                          ? Icons.emergency
                                          : Icons.check_circle_outline,
                                      color: healthResult.severity == HealthScreeningSeverity.emergency
                                          ? AppColors.emergencyRed
                                          : AppColors.primaryDark,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        healthResult.recommendation,
                                        style: AppTypography.labelLarge.copyWith(
                                          color: healthResult.severity == HealthScreeningSeverity.emergency
                                              ? const Color(0xFF991B1B)
                                              : const Color(0xFF166534),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Disclaimer (Solid Grey #616161, 100% Opacity)
                              const Text(
                                '⚠️ AI-assisted preliminary screening only. Not a confirmed medical diagnosis. No medicines or dosages prescribed. Always consult a licensed veterinarian.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.normal,
                                  color: Color(0xFF616161),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Shortcut to find nearby vets
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.location_on, size: 16),
                                      label: const Text('Find Nearby Vet Hospital'),
                                      onPressed: () => context.push('/help'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Emergency & First Aid Card (Symptom-Specific Local Rules)
              PashuCard(
                backgroundColor: const Color(0xFFFEF2F2),
                borderColor: const Color(0xFFFECACA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.emergencyRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.medical_services,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Symptom-Specific First Aid & Care Tips',
                          style: AppTypography.titleSmall.copyWith(
                            color: const Color(0xFF991B1B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDynamicFirstAidTips(
                        identifyState.selectedSymptoms,
                        _symptomNotesController.text.trim(),
                        result.firstAidInstructions,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: const Color(0xFF7F1D1D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Diet & Care Details
              PashuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Diet & Recommended Nutrition', style: AppTypography.titleSmall),
                    const SizedBox(height: 6),
                    Text(result.diet, style: AppTypography.bodyMedium),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text('Habitat & Native Range', style: AppTypography.titleSmall),
                    const SizedBox(height: 6),
                    Text(result.habitat, style: AppTypography.bodyMedium),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text('General Welfare & Care', style: AppTypography.titleSmall),
                    const SizedBox(height: 6),
                    Text(result.generalCare, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. Action Buttons
              Row(
                children: [
                  Expanded(
                    child: PashuButton(
                      text: 'Ask AI Vet',
                      icon: Icons.chat,
                      variant: PashuButtonVariant.secondary,
                      onPressed: () => context.push('/ai-assistant'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PashuButton(
                      text: 'Alert Nearby NGO',
                      icon: Icons.emergency,
                      variant: PashuButtonVariant.emergency,
                      onPressed: () => context.push('/report-emergency'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PashuButton(
                text: 'Scan Another Animal',
                variant: PashuButtonVariant.outline,
                onPressed: () => context.go('/identify'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
