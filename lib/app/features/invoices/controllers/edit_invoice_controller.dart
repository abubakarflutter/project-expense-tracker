import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/models/invoice_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/services/storage_service.dart';

class EditInvoiceController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController invoiceNumberController;
  late TextEditingController amountController;
  late TextEditingController descriptionController;

  // Observable variables
  final isLoading = false.obs;
  final projectsList = <ProjectModel>[].obs;
  final selectedProject = Rxn<ProjectModel>();
  final selectedPaymentMethod = 'bank_transfer'.obs;
  final selectedStatus = 'Paid'.obs;
  final paymentDate = Rxn<DateTime>();

  // Store the original invoice
  late InvoiceModel originalInvoice;

  // Payment method options
  final List<Map<String, String>> paymentMethodOptions = [
    {'value': 'bank_transfer', 'label': 'Bank Transfer'},
    {'value': 'cash', 'label': 'Cash'},
    {'value': 'check', 'label': 'Check'},
    {'value': 'online', 'label': 'Online Payment'},
  ];

  // Status options
  final List<String> statusOptions = ['Paid', 'Pending'];

  @override
  void onInit() {
    super.onInit();

    // Get the invoice from arguments
    originalInvoice = Get.arguments as InvoiceModel;

    // Initialize controllers
    invoiceNumberController = TextEditingController();
    amountController = TextEditingController();
    descriptionController = TextEditingController();

    loadProjects();
    loadInvoiceData();
  }

  @override
  void onClose() {
    invoiceNumberController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// Load all projects for dropdown
  void loadProjects() {
    try {
      projectsList.value = _storageService.getProjects();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load projects',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Load invoice data into fields
  void loadInvoiceData() {
    invoiceNumberController.text = originalInvoice.invoiceNumber;
    amountController.text = originalInvoice.amount.toString();
    descriptionController.text = originalInvoice.description;
    selectedPaymentMethod.value = originalInvoice.paymentMethod;
    selectedStatus.value = originalInvoice.status == 'paid' ? 'Paid' : 'Pending';
    paymentDate.value = originalInvoice.paymentDate;

    // Find and set the selected project
    try {
      final project = projectsList.firstWhere((p) => p.id == originalInvoice.projectId);
      selectedProject.value = project;
    } catch (e) {
      // Project not found
    }
  }

  /// Set selected project
  void setSelectedProject(ProjectModel? project) {
    selectedProject.value = project;
  }

  /// Set selected payment method
  void setSelectedPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  /// Set selected status
  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }

  /// Pick payment date
  Future<void> pickPaymentDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: paymentDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      paymentDate.value = picked;
    }
  }

  /// Get client name for a project
  String getClientName(String clientId) {
    final client = _storageService.getClientById(clientId);
    return client?.name ?? 'Unknown';
  }

  /// Validate invoice number
  String? validateInvoiceNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invoice number is required';
    }
    return null;
  }

  /// Validate amount
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  /// Validate description
  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    if (value.length < 3) {
      return 'Description must be at least 3 characters';
    }
    return null;
  }

  /// Update invoice in storage
  Future<void> updateInvoice() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate project selection
    if (selectedProject.value == null) {
      Get.snackbar(
        'Error',
        'Please select a project',
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

    // Validate payment date
    if (paymentDate.value == null) {
      Get.snackbar(
        'Error',
        'Please select a payment date',
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

      // Parse amount
      final amount = double.parse(amountController.text.trim());

      // Create updated invoice model (keep original ID and createdAt)
      final updatedInvoice = InvoiceModel(
        id: originalInvoice.id,
        projectId: selectedProject.value!.id,
        invoiceNumber: invoiceNumberController.text.trim(),
        amount: amount,
        paymentDate: paymentDate.value!,
        description: descriptionController.text.trim(),
        paymentMethod: selectedPaymentMethod.value,
        status: selectedStatus.value.toLowerCase(),
        createdAt: originalInvoice.createdAt,
      );

      // Update in storage
      await _storageService.updateInvoice(updatedInvoice);

      // Haptic feedback for success
      HapticFeedback.lightImpact();

      // Navigate back first
      Get.back(result: true);

      // Then show success message on the previous page
      Get.snackbar(
        'Success',
        'Invoice ${updatedInvoice.invoiceNumber} updated successfully',
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
        'Failed to update invoice: ${e.toString()}',
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

  /// Reset fields to original values
  void resetFields() {
    loadInvoiceData();
  }
}
