import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Represents a single scan history entry
class ScanHistoryEntry {
  final String id;
  final String commonName;
  final String scientificName;
  final double confidence;
  final String dangerLevel;
  final DateTime timestamp;
  final String? imageUrl;

  const ScanHistoryEntry({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.confidence,
    required this.dangerLevel,
    required this.timestamp,
    this.imageUrl,
  });

  factory ScanHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ScanHistoryEntry(
      id: json['id']?.toString() ?? '',
      commonName: json['common_name'] ?? 'Unknown Animal',
      scientificName: json['scientific_name'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      dangerLevel: json['danger_level'] ?? 'safe',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'common_name': commonName,
        'scientific_name': scientificName,
        'confidence': confidence,
        'danger_level': dangerLevel,
        'timestamp': timestamp.toIso8601String(),
        'imageUrl': imageUrl,
      };
}

/// Scan History Screen showing the last 20 confirmed animal identifications
class ScanHistoryScreen extends ConsumerWidget {
  const ScanHistoryScreen({super.key});

  Color _dangerColor(String level) {
    switch (level.toLowerCase()) {
      case 'venomous': return const Color(0xFFDC2626);
      case 'high':     return const Color(0xFFEA580C);
      case 'moderate': return const Color(0xFFD97706);
      default:         return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, this would be loaded from Riverpod provider / Hive / SharedPreferences
    const List<ScanHistoryEntry> history = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: AppColors.surface,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear History',
              onPressed: () {
                // clearScanHistory() provider call would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scan history cleared')),
                );
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No scans yet',
                    style: AppTypography.titleMedium.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan an animal to see your history here',
                    style: AppTypography.bodySmall.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                final confPct = (entry.confidence * 100).round();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _dangerColor(entry.dangerLevel).withOpacity(0.15),
                      child: Icon(Icons.pets, color: _dangerColor(entry.dangerLevel)),
                    ),
                    title: Text(entry.commonName, style: AppTypography.labelLarge),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.scientificName,
                          style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} — $confPct% confidence',
                          style: AppTypography.bodySmall.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _dangerColor(entry.dangerLevel).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _dangerColor(entry.dangerLevel).withOpacity(0.3)),
                      ),
                      child: Text(
                        '$confPct%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: _dangerColor(entry.dangerLevel),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
