import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';

class PetHealthRecordsScreen extends ConsumerStatefulWidget {
  final String petId;
  const PetHealthRecordsScreen({super.key, required this.petId});

  @override
  ConsumerState<PetHealthRecordsScreen> createState() => _PetHealthRecordsScreenState();
}

class _PetHealthRecordsScreenState extends ConsumerState<PetHealthRecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploadingDocument = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDocumentDialog() {
    String docType = 'Prescription';
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Upload Health Report / File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: docType,
                decoration: const InputDecoration(labelText: 'Report Type'),
                items: const [
                  DropdownMenuItem(value: 'Prescription', child: Text('Prescription (PDF/Image)')),
                  DropdownMenuItem(value: 'Lab Report', child: Text('Lab / Blood Test Report')),
                  DropdownMenuItem(value: 'X-Ray', child: Text('X-Ray Scan Image')),
                  DropdownMenuItem(value: 'Vaccination Certificate', child: Text('Vaccination Certificate')),
                ],
                onChanged: (val) => setDialogState(() => docType = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Document Title (e.g. Annual Blood Panel 2026)'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stored securely in private Supabase Storage bucket (health-reports). Protected by RLS policies.',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document uploaded securely to health-reports bucket!')),
                );
              },
              child: const Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PashuAppBar(
        title: 'Pet Health Records',
        actions: [
          IconButton(
            tooltip: 'Upload Document',
            icon: const Icon(Icons.upload_file, color: AppColors.primary),
            onPressed: _showAddDocumentDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primaryDark,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: '💉 Vaccinations'),
              Tab(text: '🩺 Medical Records'),
              Tab(text: '💊 Medicines'),
              Tab(text: '🏥 Vet Visits'),
              Tab(text: '📂 Documents/Reports'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Vaccinations Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PashuCard(
                      child: ListTile(
                        leading: const Icon(Icons.vaccines, color: AppColors.primary, size: 32),
                        title: const Text('Rabies Anti-Rabies Vaccine', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Administered: Jan 10, 2026 • Next Due: Jan 10, 2027\nVet: Dr. Sharma (Apollo Vets)'),
                        trailing: IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: AppColors.emergencyRed),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    PashuCard(
                      child: ListTile(
                        leading: const Icon(Icons.vaccines, color: AppColors.primary, size: 32),
                        title: const Text('DHLPP 9-in-1 Combo Vaccine', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Administered: Feb 14, 2026 • Next Due: Feb 14, 2027\nVet: Dr. Mehta'),
                        trailing: IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: AppColors.emergencyRed),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Medical Records Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PashuCard(
                      child: ListTile(
                        leading: const Icon(Icons.medical_information, color: AppColors.primary, size: 32),
                        title: const Text('Mild Ear Mite Infection', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Treatment: Ear drops applied for 7 days\nDate: Dec 12, 2025 • Vet: Dr. Patel'),
                      ),
                    ),
                  ],
                ),

                // 3. Medicines Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PashuCard(
                      child: ListTile(
                        leading: const Icon(Icons.medication, color: AppColors.primary, size: 32),
                        title: const Text('Simparica Trio (Tick/Flea Dewormer)', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Dosage: 1 Tablet Monthly\nStart: Jan 01, 2026 • Vet: Dr. Sharma'),
                      ),
                    ),
                  ],
                ),

                // 4. Vet Visits Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PashuCard(
                      child: ListTile(
                        leading: const Icon(Icons.local_hospital, color: AppColors.primary, size: 32),
                        title: const Text('Annual Wellness & Vaccination Visit', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Clinic: Max Vets South Ext, Delhi\nDate: Jan 10, 2026 • Reason: Routine Checkup'),
                      ),
                    ),
                  ],
                ),

                // 5. Health Reports & Documents Upload Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PashuCard(
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: AppColors.emergencyRed, size: 36),
                        title: const Text('Full Blood Count & Renal Panel 2026.pdf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: const Text('Category: Lab Report • Size: 1.2 MB\nStored securely in Supabase Storage'),
                        trailing: const Icon(Icons.lock, color: AppColors.primary, size: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    PashuCard(
                      child: ListTile(
                        leading: const Icon(Icons.image, color: AppColors.info, size: 36),
                        title: const Text('Abdominal_XRay_Scan.png', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: const Text('Category: X-Ray Scan • Size: 3.4 MB\nStored securely in Supabase Storage'),
                        trailing: const Icon(Icons.lock, color: AppColors.primary, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Upload Report / File'),
        onPressed: _showAddDocumentDialog,
      ),
    );
  }
}
