import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/client_model.dart';
import '../../../data/services/storage_service.dart';

class EditClientController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController companyController;

  // Observable variables
  final isLoading = false.obs;
  late ClientModel client;

  @override
  void onInit() {
    super.onInit();

    // Get client from arguments
    client = Get.arguments as ClientModel;

    // Initialize controllers with existing data
    nameController = TextEditingController(text: client.name);
    emailController = TextEditingController(text: client.email);
    phoneController = TextEditingController(text: client.phone);
    companyController = TextEditingController(text: client.company ?? '');
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    super.onClose();
  }

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  /// Validate phone
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Basic phone validation (adjust regex based on your requirements)
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    if (value.replaceAll(RegExp(r'[^\d]'), '').length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    return null;
  }

  /// Update client in storage
  Future<void> updateClient() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Create updated client model
      final updatedClient = client.copyWith(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        company: companyController.text.trim().isEmpty
            ? null
            : companyController.text.trim(),
      );

      // Update in storage
      await _storageService.updateClient(updatedClient);

      // Haptic feedback for success
      HapticFeedback.lightImpact();

      // Show success message
      Get.snackbar(
        'Success',
        'Client updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );

      // Navigate back
      Get.back(result: true);
    } catch (e) {
      // Haptic feedback for error
      HapticFeedback.heavyImpact();

      Get.snackbar(
        'Error',
        'Failed to update client: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset fields to original values
  void resetFields() {
    nameController.text = client.name;
    emailController.text = client.email;
    phoneController.text = client.phone;
    companyController.text = client.company ?? '';
  }
}
