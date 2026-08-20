import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/pashu_text_field.dart';
import '../models/medicine_reminder.dart';
import '../providers/pet_health_provider.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  const AddReminderScreen({super.key});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController(text: 'Rocky');
  final _titleController = TextEditingController();
  final _dosageController = TextEditingController(text: '1 Tablet after food');
  ReminderType _type = ReminderType.vaccine;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 3));

  @override
  void dispose() {
    _petNameController.dispose();
    _titleController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      final reminder = MedicineReminder(
        id: const Uuid().v4(),
        petName: _petNameController.text.trim(),
        title: _titleController.text.trim(),
        type: _type,
        dosage: _dosageController.text.trim(),
        scheduledTime: _scheduledDate,
      );

      ref.read(petHealthProvider.notifier).addReminder(reminder);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical reminder scheduled successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Reminder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingScreen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PashuTextField(
                  label: 'Pet Name',
                  hint: 'e.g. Rocky',
                  controller: _petNameController,
                  validator: (v) => v == null || v.isEmpty ? 'Pet name required' : null,
                ),
                const SizedBox(height: 16),

                Text('Reminder Category', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                DropdownButtonFormField<ReminderType>(
                  value: _type,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ReminderType.values.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t.label));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _type = v);
                  },
                ),
                const SizedBox(height: 16),

                PashuTextField(
                  label: 'Medicine / Vaccine Title',
                  hint: 'e.g. Anti-Rabies Vaccine Booster, Deworming Tablet',
                  controller: _titleController,
                  validator: (v) => v == null || v.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 16),

                PashuTextField(
                  label: 'Dosage & Instructions',
                  hint: 'e.g. 1 Tablet once daily with morning food',
                  controller: _dosageController,
                  validator: (v) => v == null || v.isEmpty ? 'Dosage required' : null,
                ),
                const SizedBox(height: 24),

                PashuButton(
                  text: 'Save & Set Alarm',
                  icon: Icons.alarm_on,
                  onPressed: _saveReminder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
