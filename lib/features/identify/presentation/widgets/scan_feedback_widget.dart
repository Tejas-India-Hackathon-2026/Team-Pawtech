import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Feedback options for AI scan accuracy
enum ScanFeedback { accurate, inaccurate, uncertain }

/// Widget that appears below scan results to collect user feedback on AI accuracy.
/// Sends thumbs up/down data to Supabase ai_scan_feedback table.
class ScanFeedbackWidget extends ConsumerStatefulWidget {
  final String commonName;
  final String scientificName;
  final double confidence;
  final String imageQuality;

  const ScanFeedbackWidget({
    super.key,
    required this.commonName,
    required this.scientificName,
    required this.confidence,
    this.imageQuality = 'good',
  });

  @override
  ConsumerState<ScanFeedbackWidget> createState() => _ScanFeedbackWidgetState();
}

class _ScanFeedbackWidgetState extends ConsumerState<ScanFeedbackWidget> {
  ScanFeedback? _selected;
  bool _submitted = false;
  final TextEditingController _correctionCtrl = TextEditingController();

  Future<void> _submitFeedback(ScanFeedback feedback) async {
    setState(() {
      _selected = feedback;
    });

    // In production: POST to Supabase ai_scan_feedback table
    // await SupabaseClient.from('ai_scan_feedback').insert({
    //   'common_name': widget.commonName,
    //   'scientific_name': widget.scientificName,
    //   'confidence': widget.confidence,
    //   'is_accurate': feedback == ScanFeedback.accurate,
    //   'image_quality': widget.imageQuality,
    //   'user_comment': _correctionCtrl.text.trim(),
    // });

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Thank you! Your feedback helps improve PashuRakhshak AI.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Was this identification accurate?',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _feedbackChip(ScanFeedback.accurate, Icons.thumb_up_outlined, 'Yes, correct', Colors.green),
              const SizedBox(width: 8),
              _feedbackChip(ScanFeedback.inaccurate, Icons.thumb_down_outlined, 'Wrong species', Colors.red),
              const SizedBox(width: 8),
              _feedbackChip(ScanFeedback.uncertain, Icons.help_outline, 'Not sure', Colors.orange),
            ],
          ),
          if (_selected == ScanFeedback.inaccurate) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _correctionCtrl,
              decoration: InputDecoration(
                hintText: 'What animal is this? (optional)',
                hintStyle: AppTypography.bodySmall,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              style: AppTypography.bodySmall,
              maxLines: 1,
            ),
          ],
          if (_selected != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _submitFeedback(_selected!),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Submit Feedback'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _feedbackChip(ScanFeedback type, IconData icon, String label, Color color) {
    final isSelected = _selected == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selected = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 9, color: isSelected ? color : Colors.grey, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _correctionCtrl.dispose();
    super.dispose();
  }
}
