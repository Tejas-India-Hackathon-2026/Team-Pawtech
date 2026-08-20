import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Danger level color coding guide for PashuRakhshak
/// Displayed as a dismissible bottom sheet when user taps the danger level badge.

class DangerLevelGuideSheet extends StatelessWidget {
  const DangerLevelGuideSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const DangerLevelGuideSheet(),
    );
  }

  static const List<Map<String, dynamic>> _levels = [
    {
      'level': 'Safe',
      'color': Color(0xFF059669),
      'icon': Icons.check_circle_outline,
      'description': 'Domestic or non-threatening species. Safe to approach cautiously. Examples: dogs, cats, cows, horses, common birds.',
      'action': 'Offer water and gentle care. Contact a vet if injured.'
    },
    {
      'level': 'Low Risk',
      'color': Color(0xFF0284C7),
      'icon': Icons.info_outline,
      'description': 'Generally harmless but may bite or scratch if startled. Examples: squirrels, rabbits, pigeons, small lizards.',
      'action': 'Observe from a short distance. Wear gloves if handling.'
    },
    {
      'level': 'Moderate',
      'color': Color(0xFFD97706),
      'icon': Icons.warning_amber_outlined,
      'description': 'Can cause injury if provoked. Examples: monkeys, wild boar, jackals, geese, peacocks.',
      'action': 'Do not provoke or corner. Contact local wildlife NGO for help.'
    },
    {
      'level': 'High Risk',
      'color': Color(0xFFEA580C),
      'icon': Icons.dangerous_outlined,
      'description': 'Dangerous animal capable of serious injury. Examples: bears, leopards, nilgai, crocodiles, large wolves.',
      'action': 'Maintain safe distance. Call Forest Dept: 1926 or Wildlife SOS: 1800-200-9122.'
    },
    {
      'level': 'Venomous',
      'color': Color(0xFFDC2626),
      'icon': Icons.crisis_alert,
      'description': 'Highly dangerous — can cause death. Examples: King Cobra, Indian Krait, Russell\'s Viper, Saw-scaled Viper, scorpions.',
      'action': '⚠️ EMERGENCY: Do NOT attempt handling. If bitten, immobilize limb, go to nearest hospital with anti-venom. Call 112.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Danger Level Guide', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tap any level to learn what to do', style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
          const SizedBox(height: 16),
          ..._levels.map((l) => _LevelRow(
                level: l['level'] as String,
                color: l['color'] as Color,
                icon: l['icon'] as IconData,
                description: l['description'] as String,
                action: l['action'] as String,
              )),
        ],
      ),
    );
  }
}

class _LevelRow extends StatefulWidget {
  final String level;
  final Color color;
  final IconData icon;
  final String description;
  final String action;

  const _LevelRow({required this.level, required this.color, required this.icon, required this.description, required this.action});

  @override
  State<_LevelRow> createState() => _LevelRowState();
}

class _LevelRowState extends State<_LevelRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.color.withOpacity(_expanded ? 0.5 : 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 20),
                const SizedBox(width: 8),
                Text(widget.level, style: TextStyle(fontWeight: FontWeight.w800, color: widget.color, fontSize: 13)),
                const Spacer(),
                Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: widget.color, size: 18),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(widget.description, style: AppTypography.bodySmall.copyWith(color: Colors.black87, height: 1.4)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(widget.action, style: TextStyle(fontSize: 11, color: widget.color, fontWeight: FontWeight.w700, height: 1.4)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
