import 'package:get/get.dart';

class MainController extends GetxController {
  // Current page index
  final currentIndex = 0.obs;

  // Change page
  void changePage(int index) {
    if (index >= 0 && index < 5) {
      currentIndex.value = index;
    }
  }

  // Navigate to specific page by name
  void navigateToHome() => changePage(0);
  void navigateToProjects() => changePage(1);
  void navigateToClients() => changePage(2);
  void navigateToInvoices() => changePage(3);
  void navigateToSettings() => changePage(4);

  @override
  void onInit() {
    super.onInit();
    // Initialize at home page
    currentIndex.value = 0;
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}
