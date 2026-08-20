import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine_reminder.dart';
import '../../../../core/services/notification_service.dart';

class PetHealthState {
  final List<PetHealthCard> myPets;
  final List<MedicineReminder> allReminders;
  final bool isLoading;

  const PetHealthState({
    this.myPets = const [],
    this.allReminders = const [],
    this.isLoading = false,
  });

  PetHealthState copyWith({
    List<PetHealthCard>? myPets,
    List<MedicineReminder>? allReminders,
    bool? isLoading,
  }) {
    return PetHealthState(
      myPets: myPets ?? this.myPets,
      allReminders: allReminders ?? this.allReminders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PetHealthNotifier extends StateNotifier<PetHealthState> {
  PetHealthNotifier() : super(const PetHealthState()) {
    loadHealthData();
  }

  void loadHealthData() {
    final reminders = [
      MedicineReminder(
        id: 'rem_1',
        petName: 'Rocky (Indie Dog)',
        title: 'Rabies Booster Vaccine',
        type: ReminderType.vaccine,
        dosage: '1 Dose (Subcutaneous)',
        scheduledTime: DateTime.now().add(const Duration(days: 5)),
      ),
      MedicineReminder(
        id: 'rem_2',
        petName: 'Bella (Golden Retriever)',
        title: 'Wormstop Chewable Tablet',
        type: ReminderType.deworming,
        dosage: '1 Tab with dinner',
        scheduledTime: DateTime.now().add(const Duration(hours: 6)),
      ),
      MedicineReminder(
        id: 'rem_3',
        petName: 'Rocky (Indie Dog)',
        title: 'Joint Supplement Glucosamine',
        type: ReminderType.dailyMedicine,
        dosage: '0.5 Scoop with morning meal',
        scheduledTime: DateTime.now().add(const Duration(hours: 20)),
      ),
    ];

    final pets = [
      PetHealthCard(
        petId: 'pet_rocky',
        name: 'Rocky',
        species: 'Dog',
        breed: 'Indian Pariah (Indie)',
        ageMonths: 24,
        weightKg: 18.5,
        reminders: [reminders[0], reminders[2]],
      ),
      PetHealthCard(
        petId: 'pet_bella',
        name: 'Bella',
        species: 'Dog',
        breed: 'Golden Retriever',
        ageMonths: 14,
        weightKg: 26.0,
        reminders: [reminders[1]],
      ),
    ];

    state = state.copyWith(myPets: pets, allReminders: reminders);
  }

  Future<void> addReminder(MedicineReminder reminder) async {
    final updated = [reminder, ...state.allReminders];
    state = state.copyWith(allReminders: updated);

    await NotificationService().scheduleMedicineReminder(
      id: reminder.id.hashCode,
      petName: reminder.petName,
      medicineName: reminder.title,
      scheduledTime: reminder.scheduledTime,
    );
  }

  void toggleCompletion(String reminderId) {
    final updated = state.allReminders.map((r) {
      if (r.id == reminderId) {
        return r.copyWith(isCompleted: !r.isCompleted);
      }
      return r;
    }).toList();

    state = state.copyWith(allReminders: updated);
  }
}

final petHealthProvider =
    StateNotifierProvider<PetHealthNotifier, PetHealthState>((ref) {
  return PetHealthNotifier();
});
