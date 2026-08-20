import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/payment_service.dart';
import '../../auth/presentation/providers/auth_provider.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return RazorpayPaymentService();
});

class PremiumState {
  final PaymentPlan selectedPlan;
  final bool isProcessing;
  final String? successMessage;
  final String? errorMessage;

  const PremiumState({
    this.selectedPlan = PaymentPlan.yearly999,
    this.isProcessing = false,
    this.successMessage,
    this.errorMessage,
  });

  PremiumState copyWith({
    PaymentPlan? selectedPlan,
    bool? isProcessing,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return PremiumState(
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isProcessing: isProcessing ?? this.isProcessing,
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PaymentService _paymentService;
  final Ref _ref;

  PremiumNotifier(this._paymentService, this._ref)
      : super(const PremiumState());

  void selectPlan(PaymentPlan plan) {
    state = state.copyWith(selectedPlan: plan, clearMessages: true);
  }

  Future<void> checkout() async {
    state = state.copyWith(isProcessing: true, clearMessages: true);

    final user = _ref.read(authProvider).user;
    final email = user?.email ?? 'guardian@pashurakhshak.in';
    final phone = user?.phone ?? '+919876543210';

    await _paymentService.startSubscription(
      plan: state.selectedPlan,
      userEmail: email,
      userPhone: phone,
      onComplete: (result) async {
        if (result.status == PaymentStatus.success) {
          await _ref.read(authProvider.notifier).upgradeToPremium();
          state = state.copyWith(
            isProcessing: false,
            successMessage: result.message,
          );
        } else {
          state = state.copyWith(
            isProcessing: false,
            errorMessage: result.message,
          );
        }
      },
    );
  }
}

final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return PremiumNotifier(paymentService, ref);
});
