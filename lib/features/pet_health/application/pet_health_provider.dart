import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a single pet vaccination or medicine alarm record
class PetHealthAlarm {
  final String id;
  final String petName;
  final String type; // 'vaccine' | 'medicine' | 'checkup'
  final String label;
  final DateTime dueAt;
  final bool isCompleted;

  const PetHealthAlarm({
    required this.id,
    required this.petName,
    required this.type,
    required this.label,
    required this.dueAt,
    this.isCompleted = false,
  });

  PetHealthAlarm copyWith({bool? isCompleted}) => PetHealthAlarm(
        id: id,
        petName: petName,
        type: type,
        label: label,
        dueAt: dueAt,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  bool get isOverdue => !isCompleted && dueAt.isBefore(DateTime.now());
  bool get isDueToday {
    final now = DateTime.now();
    return !isCompleted &&
        dueAt.year == now.year &&
        dueAt.month == now.month &&
        dueAt.day == now.day;
  }

  int get daysUntilDue => dueAt.difference(DateTime.now()).inDays;
}

/// State for the pet health alarms list
class PetHealthState {
  final List<PetHealthAlarm> alarms;
  final bool isLoading;
  final String? error;

  const PetHealthState({
    this.alarms = const [],
    this.isLoading = false,
    this.error,
  });

  PetHealthState copyWith({List<PetHealthAlarm>? alarms, bool? isLoading, String? error}) =>
      PetHealthState(
        alarms: alarms ?? this.alarms,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  List<PetHealthAlarm> get overdueAlarms => alarms.where((a) => a.isOverdue).toList();
  List<PetHealthAlarm> get todayAlarms => alarms.where((a) => a.isDueToday).toList();
  List<PetHealthAlarm> get upcomingAlarms =>
      alarms.where((a) => !a.isCompleted && !a.isOverdue && !a.isDueToday).toList();
}

/// Riverpod StateNotifier for pet health alarm management
class PetHealthNotifier extends StateNotifier<PetHealthState> {
  PetHealthNotifier() : super(const PetHealthState()) {
    _loadDemoAlarms();
  }

  void _loadDemoAlarms() {
    final now = DateTime.now();
    state = state.copyWith(
      alarms: [
        PetHealthAlarm(
          id: 'a1',
          petName: 'Rocky',
          type: 'vaccine',
          label: 'Rabies Booster',
          dueAt: now.add(const Duration(days: 5)),
        ),
        PetHealthAlarm(
          id: 'a2',
          petName: 'Bella',
          type: 'medicine',
          label: 'Deworming Dose',
          dueAt: DateTime(now.year, now.month, now.day, 20, 0),
        ),
        PetHealthAlarm(
          id: 'a3',
          petName: 'Rocky',
          type: 'checkup',
          label: 'Annual Wellness Check',
          dueAt: now.add(const Duration(days: 30)),
        ),
        PetHealthAlarm(
          id: 'a4',
          petName: 'Gau Mata',
          type: 'vaccine',
          label: 'FMD Vaccination',
          dueAt: now.subtract(const Duration(days: 2)), // Overdue
        ),
      ],
    );
  }

  /// Mark a specific alarm as completed
  void markCompleted(String alarmId) {
    state = state.copyWith(
      alarms: state.alarms.map((a) => a.id == alarmId ? a.copyWith(isCompleted: true) : a).toList(),
    );
  }

  /// Add a new alarm
  void addAlarm(PetHealthAlarm alarm) {
    state = state.copyWith(alarms: [alarm, ...state.alarms]);
  }

  /// Remove an alarm by id
  void removeAlarm(String alarmId) {
    state = state.copyWith(alarms: state.alarms.where((a) => a.id != alarmId).toList());
  }

  /// Snooze an alarm by a given number of days
  void snoozeAlarm(String alarmId, {int days = 1}) {
    state = state.copyWith(
      alarms: state.alarms.map((a) {
        if (a.id != alarmId) return a;
        return PetHealthAlarm(
          id: a.id,
          petName: a.petName,
          type: a.type,
          label: a.label,
          dueAt: a.dueAt.add(Duration(days: days)),
        );
      }).toList(),
    );
  }
}

/// Global Riverpod provider for pet health alarm state
final petHealthProvider = StateNotifierProvider<PetHealthNotifier, PetHealthState>(
  (ref) => PetHealthNotifier(),
);

/// Computed provider: count of overdue alarms (shown as badge on nav)
final overdueAlarmsCountProvider = Provider<int>((ref) {
  return ref.watch(petHealthProvider).overdueAlarms.length;
});
