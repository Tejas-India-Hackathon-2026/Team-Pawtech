import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';

class HealthTrendsScreen extends ConsumerStatefulWidget {
  final String petId;
  const HealthTrendsScreen({super.key, required this.petId});

  @override
  ConsumerState<HealthTrendsScreen> createState() => _HealthTrendsScreenState();
}

class _HealthTrendsScreenState extends ConsumerState<HealthTrendsScreen> {
  bool _permissionGranted = true;
  bool _isSummarizing = false;
  String _aiSummaryText = '';

  final List<Map<String, dynamic>> _weightHistory = [
    {'month': 'Jan', 'weight': 3.8},
    {'month': 'Feb', 'weight': 4.0},
    {'month': 'Mar', 'weight': 4.2},
    {'month': 'Apr', 'weight': 4.5},
    {'month': 'May', 'weight': 4.6},
    {'month': 'Jun', 'weight': 4.5},
  ];

  void _generateAiSummary() async {
    if (!_permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission required: Please enable permission to allow AI to process pet health records.')),
      );
      return;
    }

    setState(() => _isSummarizing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isSummarizing = false;
      _aiSummaryText =
          '🐾 AI Health Summary for Leo:\n'
          '• Weight Trend: Healthy linear weight gain from 3.8kg (Jan) to 4.5kg (Jun). Standard growth curve for 6-month-old Indie breed.\n'
          '• Vaccination Status: Anti-Rabies & DHLPP vaccines are UP TO DATE. Next booster due in Jan 2027.\n'
          '• Medical Records: Past ear mite infection successfully resolved in Dec 2025.\n\n'
          '⚠️ Important Veterinary Disclaimer:\n'
          'This summary is AI-generated for informational guidance only. It is NOT a medical diagnosis or prescription. For serious symptoms, severe bleeding, fever, or lethargy, please consult a qualified veterinarian immediately.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PashuAppBar(title: 'Pet Health AI & Trend Analytics'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'AI uses pet stored health records only when permissioned.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                  Switch(
                    value: _permissionGranted,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _permissionGranted = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weight Trend Visualization Chart Card
            Text('Weight Trend Visualization (kg)', style: AppTypography.titleSmall),
            const SizedBox(height: 10),
            PashuCard(
              hasShadow: true,
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _WeightChartPainter(_weightHistory),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weightHistory.map((item) => Text(
                      '${item['month']}\n${item['weight']}kg',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Health Summarizer
            Text('AI Health Record Summarization', style: AppTypography.titleSmall),
            const SizedBox(height: 10),
            PashuCard(
              hasShadow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Generate Health Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_aiSummaryText.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _aiSummaryText,
                        style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isSummarizing ? null : _generateAiSummary,
                      icon: const Icon(Icons.summarize),
                      label: _isSummarizing
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Summarize Health Records'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mandatory Vet Safety Warning Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.emergencyRedContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: const [
                  Icon(Icons.local_hospital, color: AppColors.emergencyRed),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For serious medical symptoms or emergencies:\n"Please consult a qualified veterinarian immediately."',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emergencyRed),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> history;
  _WeightChartPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paintLine = Paint()
      :color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;

    final path = Path();
    final stepX = size.width / (history.length - 1);

    for (int i = 0; i < history.length; i++) {
      final w = (history[i]['weight'] as num).toDouble();
      // map weight 3.5kg -> 5.0kg to height range
      final normalizedY = size.height - ((w - 3.5) / 1.5) * (size.height - 30) - 15;
      final x = i * stepX;

      if (i == 0) {
        path.moveTo(x, normalizedY);
      } else {
        path.lineTo(x, normalizedY);
      }

      canvas.drawCircle(Offset(x, normalizedY), 5, paintDot);
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
