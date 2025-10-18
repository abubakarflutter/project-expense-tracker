import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/services/storage_service.dart';

class AddProjectController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController totalBudgetController;

  // Observable variables
  final isLoading = false.obs;
  final clientsList = <ClientModel>[].obs;
  final selectedClient = Rxn<ClientModel>();
  final selectedStatus = 'Active'.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  // Status options
  final List<String> statusOptions = ['Active', 'Completed', 'On-hold'];

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    totalBudgetController = TextEditingController();
    loadClients();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    totalBudgetController.dispose();
    super.onClose();
  }

  /// Load all clients for dropdown
  void loadClients() {
    try {
      clientsList.value = _storageService.getClients();
      if (clientsList.isEmpty) {
        Get.snackbar(
          'No Clients',
          'Please add a client first before creating a project',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load clients',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Set selected client
  void setSelectedClient(ClientModel? client) {
    selectedClient.value = client;
  }

  /// Set selected status
  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }

  /// Pick start date
  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      startDate.value = picked;
      // If end date is before start date, clear it
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = null;
      }
    }
  }

  /// Pick end date
  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? startDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      endDate.value = picked;
    }
  }

  /// Validate project name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Project name is required';
    }
    if (value.length < 3) {
      return 'Project name must be at least 3 characters';
    }
    return null;
  }

  /// Validate budget
  String? validateBudget(String? value) {
    if (value == null || value.isEmpty) {
      return 'Budget is required';
    }

    final budget = double.tryParse(value);
    if (budget == null) {
      return 'Please enter a valid number';
    }

    if (budget <= 0) {
      return 'Budget must be greater than 0';
    }

    return null;
  }

  /// Validate client selection
  String? validateClient() {
    if (selectedClient.value == null) {
      return 'Please select a client';
    }
    return null;
  }

  /// Save project to storage
  Future<void> saveProject() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate client selection
    if (selectedClient.value == null) {
      Get.snackbar(
        'Error',
        'Please select a client',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(PhosphorIconsRegular.warning, color: Colors.white),
      );
      return;
    }

    try {
      isLoading.value = true;

      // Parse budget
      final budget = double.parse(totalBudgetController.text.trim());

      // Create project model
      final project = ProjectModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        clientId: selectedClient.value!.id,
        totalBudget: budget,
        totalReceived: 0.0,
        status: selectedStatus.value,
        startDate: startDate.value,
        endDate: endDate.value,
        createdAt: DateTime.now(),
      );

      // Save to storage
      await _storageService.saveProject(project);

      // Haptic feedback for success
      HapticFeedback.lightImpact();

      // Navigate back first
      Get.back(result: true);

      // Then show success message on the previous page
      Get.snackbar(
        'Success',
        'Project "${project.name}" added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(PhosphorIconsRegular.checkCircle, color: Colors.white),
      );
    } catch (e) {
      // Haptic feedback for error
      HapticFeedback.heavyImpact();

      Get.snackbar(
        'Error',
        'Failed to add project: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(PhosphorIconsRegular.xCircle, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all fields
  void clearFields() {
    nameController.clear();
    descriptionController.clear();
    totalBudgetController.clear();
    selectedClient.value = null;
    selectedStatus.value = 'Active';
    startDate.value = null;
    endDate.value = null;
  }
}
