import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class PremiumMembershipScreen extends ConsumerStatefulWidget {
  const PremiumMembershipScreen({super.key});

  @override
  ConsumerState<PremiumMembershipScreen> createState() => _PremiumMembershipScreenState();
}

class _PremiumMembershipScreenState extends ConsumerState<PremiumMembershipScreen> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly999;
  late PaymentService _paymentService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _subscribe() {
    final authState = ref.read(authProvider);
    final user = authState.user;

    setState(() => _isProcessing = true);

    _paymentService.startRazorpayCheckout(
      plan: _selectedPlan,
      userEmail: user?.email ?? 'user@pawfinder.in',
      userPhone: user?.phone ?? '9876543210',
      onSuccess: (paymentId, orderId) async {
        if (user != null) {
          await PaymentService.recordSubscriptionInDatabase(
            userId: user.id,
            plan: _selectedPlan,
            razorpayOrderId: orderId,
            razorpayPaymentId: paymentId,
          );
        }
        if (mounted) {
          setState(() => _isProcessing = false);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
                  SizedBox(width: 8),
                  Text('Welcome to Premium!'),
                ],
              ),
              content: const Text(
                'Payment verified! Your account is now upgraded to Premium Membership. Enjoy an Ad-Free experience, Priority AI Chatbot, and Advanced Health Analytics.',
                style: TextStyle(fontSize: 13),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.pop();
                  },
                  child: const Text('Great!'),
                ),
              ],
            ),
          );
        }
      },
      onError: (errorMsg) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Error: $errorMsg')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAlreadyPremium = authState.user?.isPremium ?? false;

    return Scaffold(
      appBar: const PashuAppBar(title: 'PawFinder Premium'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.amber, size: 54),
                  const SizedBox(height: 10),
                  const Text(
                    'PawFinder Premium Membership',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAlreadyPremium ? '✓ Active Premium Subscriber' : 'Unlock full pet health tracking & priority AI assistance',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pricing Options
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPlan = SubscriptionPlan.monthly99),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedPlan == SubscriptionPlan.monthly99 ? AppColors.primaryContainer : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedPlan == SubscriptionPlan.monthly99 ? AppColors.primary : AppColors.outline,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: const [
                          Text('Monthly', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 6),
                          Text('₹99 / month', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark)),
                          SizedBox(height: 4),
                          Text('Flexible monthly billing', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPlan = SubscriptionPlan.yearly999),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedPlan == SubscriptionPlan.yearly999 ? AppColors.primaryContainer : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedPlan == SubscriptionPlan.yearly999 ? AppColors.primary : AppColors.outline,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(6)),
                              child: const Text('BEST VALUE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Column(
                            children: const [
                              Text('Yearly', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              SizedBox(height: 6),
                              Text('₹999 / year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark)),
                              SizedBox(height: 4),
                              Text('Save ₹189 (15% OFF)', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Features Checklist
            Text('Included Premium Features', style: AppTypography.titleSmall),
            const SizedBox(height: 12),
            _buildFeatureTile(Icons.medical_services_outlined, 'Detailed Pet Health Tracking & Records'),
            _buildFeatureTile(Icons.notifications_active_outlined, 'Unlimited Vaccination & Medicine Reminders'),
            _buildFeatureTile(Icons.smart_toy_outlined, 'Priority Access to PashuMitra AI Chatbot'),
            _buildFeatureTile(Icons.verified_outlined, 'Verified Seller Badge Eligibility'),
            _buildFeatureTile(Icons.block_outlined, '100% Ad-Free Application Experience'),
            _buildFeatureTile(Icons.analytics_outlined, 'Advanced Health & Weight Analytics Charts'),
            _buildFeatureTile(Icons.cloud_upload_outlined, 'Unlimited Document & Report Storage Capacity'),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isProcessing ? null : _subscribe,
                icon: const Icon(Icons.payment),
                label: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isAlreadyPremium ? 'Extend Subscription (Razorpay)' : 'Subscribe Now via Razorpay (₹${_selectedPlan.priceInr})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }
}
