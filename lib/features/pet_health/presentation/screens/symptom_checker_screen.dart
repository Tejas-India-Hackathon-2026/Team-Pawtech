import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/pashu_card.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final List<String> _selectedSymptoms = [];
  bool _showAnalysis = false;

  final symptoms = [
    'Vomiting (Repeated)',
    'Lethargy & Not Eating',
    'Limping / Leg Injury',
    'Excessive Scratching / Ticks',
    'Coughing / Wheezing',
    'Loose Stool / Diarrhea',
    'Shivering / High Body Temp',
    'Red Eyes / Discharge',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Symptom Triage'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What symptoms is your animal showing?',
                style: AppTypography.displayMedium.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                'Select observed signs to receive immediate triage steps and urgency rating.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: symptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom),
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              PashuButton(
                text: 'Analyze Symptoms with AI',
                icon: Icons.auto_awesome,
                onPressed: _selectedSymptoms.isNotEmpty
                    ? () => setState(() => _showAnalysis = true)
                    : null,
              ),
              const SizedBox(height: 24),

              if (_showAnalysis) ...[
                PashuCard(
                  backgroundColor: const Color(0xFFFEF3C7),
                  borderColor: const Color(0xFFFDE68A),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Color(0xFFD97706)),
                          const SizedBox(width: 8),
                          Text(
                            'Triage Assessment: Moderate Concern',
                            style: AppTypography.titleSmall.copyWith(
                              color: const Color(0xFFB45309),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on ${_selectedSymptoms.join(", ")}, your pet may have gastrointestinal irritation or mild infection. Do not offer heavy food or human NSAID painkillers (paracetamol/ibuprofen are toxic to dogs/cats). Keep hydrated with ORS water in small quantities and visit a vet within 24 hours if symptoms persist.',
                        style: AppTypography.bodyMedium.copyWith(color: const Color(0xFF92400E)),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.push('/ai-assistant'),
                              child: const Text('Ask Pashu Mitra AI'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary),
                              onPressed: () => context.push('/help'),
                              child: const Text('Find Nearest Vet',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
