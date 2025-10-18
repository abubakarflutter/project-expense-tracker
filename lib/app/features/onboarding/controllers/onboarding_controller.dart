import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../home/views/main_view.dart';

class OnboardingController extends GetxController {
  final GetStorage _storage = GetStorage();

  // Storage key for onboarding completion
  static const String _onboardingKey = 'has_completed_onboarding';

  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // No auto-check - onboarding always shows
  }

  /// Navigate to home and mark onboarding as completed
  Future<void> navigateToHome() async {
    try {
      isLoading.value = true;

      // Save flag to skip onboarding on next launch
      await _storage.write(_onboardingKey, true);

      // Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to home and remove all previous routes
      Get.offAll(() => const MainView());
    } catch (e) {
      // Handle error
      Get.snackbar(
        'Error',
        'Failed to proceed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset onboarding status (useful for testing or settings)
  Future<void> resetOnboarding() async {
    await _storage.remove(_onboardingKey);
  }

  /// Check if onboarding has been completed
  bool hasCompletedOnboarding() {
    return _storage.read<bool>(_onboardingKey) ?? false;
  }
}
