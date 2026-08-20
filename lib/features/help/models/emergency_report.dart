enum EmergencySeverity {
  critical, // Life threatening
  moderate, // Injured/sick
  minor, // Needs checkup
}

enum RescueStatus {
  reported,
  assigned,
  enRoute,
  rescued,
  closed,
}

class EmergencyReport {
  final String id;
  final String animalType;
  final String conditionDescription;
  final EmergencySeverity severity;
  final String address;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final String reporterPhone;
  final RescueStatus status;
  final DateTime reportedAt;
  final String? assignedNgoName;

  EmergencyReport({
    required this.id,
    required this.animalType,
    required this.conditionDescription,
    required this.severity,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.reporterPhone,
    this.status = RescueStatus.reported,
    DateTime? reportedAt,
    this.assignedNgoName,
  }) : reportedAt = reportedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'animal_type': animalType,
        'condition': conditionDescription,
        'urgency_level': severity.name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'photo_url': photoUrl,
        'reporter_phone': reporterPhone,
        'status': status.name,
        'reported_at': reportedAt.toIso8601String(),
        'assigned_ngo_name': assignedNgoName,
      };
}
