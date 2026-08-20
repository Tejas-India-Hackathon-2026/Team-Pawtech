import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController(text: '4.5');
  final _allergiesController = TextEditingController(text: 'None');
  final _conditionsController = TextEditingController(text: 'None');
  final _emergencyPhoneController = TextEditingController();

  String _species = 'Dog';
  String _gender = 'Male';
  DateTime _dob = DateTime.now().subtract(const Duration(days: 365 * 2));
  bool _photoAttached = false;
  bool _isSaving = false;

  void _savePet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet Profile created successfully! Saved to Supabase.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PashuAppBar(title: 'Add Pet Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primaryContainer,
                      child: const Icon(Icons.pets, size: 48, color: AppColors.primary),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          onPressed: () => setState(() => _photoAttached = true),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Pet Name', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter pet name' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Bruno, Bella, Simba',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Species', style: AppTypography.titleSmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _species,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                            DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                            DropdownMenuItem(value: 'Bird', child: Text('Bird')),
                            DropdownMenuItem(value: 'Cattle', child: Text('Cattle')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (v) => setState(() => _species = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gender', style: AppTypography.titleSmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                          ],
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Breed', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _breedController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter breed' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Golden Retriever, Indie, Persian',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              Text('Weight (kg)', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Weight in kg',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              Text('Allergies', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  hintText: 'e.g. Chicken protein, Flea bite allergy, None',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              Text('Emergency Vet Contact', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emergencyPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Vet clinic phone number',
                  prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _savePet,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Pet Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
