enum ReminderType {
  vaccine,
  deworming,
  dailyMedicine,
  vetCheckup,
}

extension ReminderTypeDetails on ReminderType {
  String get label {
    switch (this) {
      case ReminderType.vaccine:
        return 'Vaccination';
      case ReminderType.deworming:
        return 'Deworming';
      case ReminderType.dailyMedicine:
        return 'Daily Medicine';
      case ReminderType.vetCheckup:
        return 'Vet Checkup';
    }
  }
}

class MedicineReminder {
  final String id;
  final String petName;
  final String title;
  final ReminderType type;
  final String dosage;
  final DateTime scheduledTime;
  final bool isCompleted;

  MedicineReminder({
    required this.id,
    required this.petName,
    required this.title,
    required this.type,
    required this.dosage,
    required this.scheduledTime,
    this.isCompleted = false,
  });

  MedicineReminder copyWith({bool? isCompleted}) {
    return MedicineReminder(
      id: id,
      petName: petName,
      title: title,
      type: type,
      dosage: dosage,
      scheduledTime: scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class PetHealthCard {
  final String petId;
  final String name;
  final String species;
  final String breed;
  final int ageMonths;
  final double weightKg;
  final String microchipNumber;
  final List<MedicineReminder> reminders;

  PetHealthCard({
    required this.petId,
    required this.name,
    required this.species,
    required this.breed,
    required this.ageMonths,
    required this.weightKg,
    this.microchipNumber = '9810-IND-2024-88',
    this.reminders = const [],
  });
}
