import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/models/invoice_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/services/storage_service.dart';

class AddInvoiceController extends GetxController {
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
    invoiceNumberController = TextEditingController();
    amountController = TextEditingController();
    descriptionController = TextEditingController();

    loadProjects();
    generateInvoiceNumber();

    // Set default payment date to today
    paymentDate.value = DateTime.now();
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
      if (projectsList.isEmpty) {
        Get.snackbar(
          'No Projects',
          'Please add a project first before creating an invoice',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load projects',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Auto-generate invoice number
  void generateInvoiceNumber() {
    final invoices = _storageService.getInvoices();
    final nextNumber = invoices.length + 1;
    final invoiceNumber =
        'INV-${DateTime.now().year}-${nextNumber.toString().padLeft(4, '0')}';
    invoiceNumberController.text = invoiceNumber;
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

  /// Save invoice to storage
  Future<void> saveInvoice() async {
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

      // Create invoice model
      final invoice = InvoiceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: selectedProject.value!.id,
        invoiceNumber: invoiceNumberController.text.trim(),
        amount: amount,
        paymentDate: paymentDate.value!,
        description: descriptionController.text.trim(),
        paymentMethod: selectedPaymentMethod.value,
        status: selectedStatus.value.toLowerCase(),
        createdAt: DateTime.now(),
      );

      // Save to storage (this will auto-update the project's totalReceived)
      await _storageService.saveInvoice(invoice);

      // Haptic feedback for success
      HapticFeedback.lightImpact();

      // Navigate back first
      Get.back(result: true);

      // Then show success message on the previous page
      Get.snackbar(
        'Success',
        'Invoice ${invoice.invoiceNumber} added successfully',
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
        'Failed to add invoice: ${e.toString()}',
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
    invoiceNumberController.clear();
    amountController.clear();
    descriptionController.clear();
    selectedProject.value = null;
    selectedPaymentMethod.value = 'bank_transfer';
    selectedStatus.value = 'Paid';
    paymentDate.value = DateTime.now();
    generateInvoiceNumber();
  }
}
