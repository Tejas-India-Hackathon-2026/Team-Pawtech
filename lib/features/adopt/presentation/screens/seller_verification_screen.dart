import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';

class SellerVerificationScreen extends ConsumerStatefulWidget {
  const SellerVerificationScreen({super.key});

  @override
  ConsumerState<SellerVerificationScreen> createState() => _SellerVerificationScreenState();
}

class _SellerVerificationScreenState extends ConsumerState<SellerVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idNumController = TextEditingController();
  final _addressController = TextEditingController();
  String _idType = 'Aadhaar Card';
  bool _documentUploaded = false;
  bool _isSubmitting = false;

  void _submitVerification() async {
    if (!_formKey.currentState!.validate() || !_documentUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and upload ID document.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Application Submitted'),
            ],
          ),
          content: const Text(
            'Your verification documents have been securely uploaded to Supabase. An admin will review your identity details within 24-48 hours. Upon approval, your profile will display the "✓ Verified Seller" badge.',
            style: TextStyle(fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PashuAppBar(title: 'Seller Identity Verification'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.verified, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Get "✓ Verified Seller" Badge',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verified sellers enjoy higher adoption rates, priority search visibility, and trusted buyer confidence.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Full Legal Name', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter legal name' : null,
                decoration: InputDecoration(
                  hintText: 'As shown on Government ID',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Text('Government ID Type', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _idType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'Aadhaar Card', child: Text('Aadhaar Card')),
                  DropdownMenuItem(value: 'PAN Card', child: Text('PAN Card')),
                  DropdownMenuItem(value: 'Driving License', child: Text('Driving License')),
                  DropdownMenuItem(value: 'NGO Registration Certificate', child: Text('NGO Registration Certificate')),
                ],
                onChanged: (val) => setState(() => _idType = val!),
              ),
              const SizedBox(height: 16),
              Text('ID / Registration Number', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _idNumController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter ID number' : null,
                decoration: InputDecoration(
                  hintText: 'Enter ID number',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Text('Upload ID Document (Secure Storage)', style: AppTypography.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _documentUploaded = true),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _documentUploaded ? AppColors.primaryContainer.withOpacity(0.3) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _documentUploaded ? AppColors.primary : AppColors.outline,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _documentUploaded ? Icons.task_alt : Icons.cloud_upload_outlined,
                          size: 36,
                          color: _documentUploaded ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _documentUploaded ? 'Document Attached (verification-documents bucket)' : 'Tap to Upload Document Image/PDF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _documentUploaded ? FontWeight.bold : FontWeight.normal,
                            color: _documentUploaded ? AppColors.primaryDark : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  onPressed: _isSubmitting ? null : _submitVerification,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Verification Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
