import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/pashu_text_field.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../models/pet_listing.dart';
import '../providers/adopt_provider.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _breedController = TextEditingController();
  final _speciesController = TextEditingController(text: 'Dog');
  final _ageController = TextEditingController(text: '6');
  final _priceController = TextEditingController(text: '0');
  final _locationController = TextEditingController(text: 'New Delhi, India');
  final _descController = TextEditingController();

  PetCategory _category = PetCategory.dogs;
  bool _isFreeAdoption = true;
  bool _isVaccinated = true;
  bool _isDewormed = true;
  String _gender = 'Male';

  @override
  void dispose() {
    _titleController.dispose();
    _breedController.dispose();
    _speciesController.dispose();
    _ageController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitListing() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authProvider).user;
      final newPet = PetListing(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        species: _speciesController.text.trim(),
        breed: _breedController.text.trim(),
        category: _category,
        ageMonths: int.tryParse(_ageController.text) ?? 6,
        gender: _gender,
        priceInr: _isFreeAdoption ? 0 : (int.tryParse(_priceController.text) ?? 0),
        isFreeAdoption: _isFreeAdoption,
        isVaccinated: _isVaccinated,
        isDewormed: _isDewormed,
        location: _locationController.text.trim(),
        description: _descController.text.trim(),
        imageUrls: ['assets/images/sample_dog.jpg'],
        sellerName: user?.fullName ?? 'Verified Guardian',
        sellerPhone: user?.phone ?? '+91 98765 43210',
        createdAt: DateTime.now(),
      );

      ref.read(adoptProvider.notifier).addListing(newPet);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet listed successfully on PashuRakhshak!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Animal for Adoption / Sale'),
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
                  label: 'Listing Title',
                  hint: 'e.g. Friendly Labrador Puppy for Adoption',
                  controller: _titleController,
                  validator: (v) => v == null || v.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: PashuTextField(
                        label: 'Species',
                        hint: 'Dog, Cat, Cow, etc.',
                        controller: _speciesController,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PashuTextField(
                        label: 'Breed',
                        hint: 'e.g. Indie, Persian, Gir',
                        controller: _breedController,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Category', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                DropdownButtonFormField<PetCategory>(
                  value: _category,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: PetCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.label),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: PashuTextField(
                        label: 'Age (in Months)',
                        hint: 'e.g. 4',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Male', child: Text('Male')),
                              DropdownMenuItem(value: 'Female', child: Text('Female')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _gender = v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text('Free Animal Adoption'),
                  subtitle: const Text('Encouraged for rescued strays and shelter pets'),
                  value: _isFreeAdoption,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _isFreeAdoption = v),
                ),

                if (!_isFreeAdoption) ...[
                  PashuTextField(
                    label: 'Price in INR (₹)',
                    hint: 'e.g. 5000',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.currency_rupee),
                  ),
                  const SizedBox(height: 16),
                ],

                CheckboxListTile(
                  title: const Text('Vaccinated with core vaccines'),
                  value: _isVaccinated,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _isVaccinated = v ?? false),
                ),

                CheckboxListTile(
                  title: const Text('Dewormed regularly'),
                  value: _isDewormed,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _isDewormed = v ?? false),
                ),
                const SizedBox(height: 12),

                PashuTextField(
                  label: 'City / Location',
                  hint: 'e.g. Koramangala, Bangalore',
                  controller: _locationController,
                  validator: (v) => v == null || v.isEmpty ? 'Location required' : null,
                ),
                const SizedBox(height: 16),

                PashuTextField(
                  label: 'Description & Health Notes',
                  hint: 'Mention temperament, feeding habit, personality...',
                  controller: _descController,
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Description required' : null,
                ),
                const SizedBox(height: 24),

                PashuButton(
                  text: 'Publish Animal Listing',
                  icon: Icons.check,
                  onPressed: _submitListing,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
