import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/tag_badge.dart';
import '../../../../shared/widgets/custom_bottom_nav.dart';
import '../../../../l10n/l10n.dart';
import '../models/pet_health_model.dart';
import '../providers/pet_health_provider.dart';

class PetHealthDashboardScreen extends ConsumerWidget {
  const PetHealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(petHealthProvider);
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;
    final selectedPet = healthState.selectedPet;

    return Scaffold(
      appBar: PashuAppBar(
        title: AppLanguages.get('petHealth', lang),
        actions: [
          IconButton(
            tooltip: 'Add Pet Profile',
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => context.push('/pet-health/add-pet'),
          ),
          IconButton(
            tooltip: 'AI Health Analytics',
            icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
            onPressed: () => context.push('/pet-health/trends/${selectedPet?.id ?? "pet_1"}'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Selector Switcher
              SizedBox(
                height: 75,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: healthState.pets.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == healthState.pets.length) {
                      return InkWell(
                        onTap: () => context.push('/pet-health/add-pet'),
                        child: Container(
                          width: 65,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(Icons.add, color: AppColors.primary, size: 28),
                          ),
                        ),
                      );
                    }

                    final pet = healthState.pets[index];
                    final isSelected = selectedPet?.id == pet.id;

                    return ChoiceChip(
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      avatar: CircleAvatar(
                        backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                        child: Text(pet.name[0], style: const TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pet.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? AppColors.primaryDark : AppColors.textPrimary)),
                            Text('${pet.species} • ${pet.ageYears} yrs', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      onSelected: (_) => ref.read(petHealthProvider.notifier).selectPet(pet.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              if (selectedPet != null) ...[
                // Selected Pet Profile Summary Card
                PashuCard(
                  hasShadow: true,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryContainer,
                            child: const Icon(Icons.pets, size: 30, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(selectedPet.name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                                Text('${selectedPet.breed} (${selectedPet.gender})', style: AppTypography.bodySmall),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    TagBadge(text: '${selectedPet.weightKg} kg', variant: TagVariant.primary),
                                    const SizedBox(width: 6),
                                    TagBadge(text: 'Allergies: ${selectedPet.allergies}', variant: TagVariant.warning),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.folder_shared_outlined, size: 18),
                            label: const Text('Health Records'),
                            onPressed: () => context.push('/pet-health/records/${selectedPet.id}'),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('AI Health Trends'),
                            onPressed: () => context.push('/pet-health/trends/${selectedPet.id}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Health Reminders & Notifications Section (Vaccinations, Medicines, Vet visits)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Scheduled Health Reminders', style: AppTypography.titleSmall),
                  TextButton.icon(
                    icon: const Icon(Icons.add_alarm, size: 16, color: AppColors.primary),
                    label: const Text('Add Reminder'),
                    onPressed: () => context.push('/pet-health/add-reminder'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (healthState.reminders.isEmpty)
                const Center(child: Text('No reminders scheduled.'))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: healthState.reminders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final reminder = healthState.reminders[index];
                    return PashuCard(
                      child: Row(
                        children: [
                          Icon(
                            reminder.type == ReminderType.vaccination
                                ? Icons.vaccines
                                : reminder.type == ReminderType.medicine
                                    ? Icons.medication
                                    : Icons.local_hospital,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${reminder.dateFormatted} • ${reminder.petName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Snooze 1 Day',
                            icon: const Icon(Icons.snooze, color: AppColors.textMuted, size: 20),
                            onPressed: () {
                              ref.read(petHealthProvider.notifier).snoozeReminder(reminder.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reminder snoozed for 24 hours.')),
                              );
                            },
                          ),
                          Switch(
                            value: reminder.isEnabled,
                            activeColor: AppColors.primary,
                            onChanged: (_) => ref.read(petHealthProvider.notifier).toggleReminder(reminder.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}
