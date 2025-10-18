import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/services/storage_service.dart';
import '../views/add_invoice_view.dart';
import '../views/edit_invoice_view.dart';

class InvoicesController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Observable variables
  final invoicesList = <InvoiceModel>[].obs;
  final projectsList = <ProjectModel>[].obs;
  final clientsList = <ClientModel>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs;

  // Filter options
  final List<String> filterOptions = ['all', 'paid', 'pending'];

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  /// Load all invoices, projects, and clients from storage
  Future<void> loadInvoices() async {
    try {
      isLoading.value = true;
      invoicesList.value = _storageService.getInvoices();
      projectsList.value = _storageService.getProjects();
      clientsList.value = _storageService.getClients();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load invoices',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered invoices based on selected filter
  List<InvoiceModel> get filteredInvoices {
    if (selectedFilter.value == 'all') {
      return invoicesList;
    }
    return invoicesList
        .where((invoice) =>
            invoice.status.toLowerCase() == selectedFilter.value.toLowerCase())
        .toList();
  }

  /// Set the selected filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// Get project name by ID
  String getProjectName(String projectId) {
    try {
      final project = projectsList.firstWhere((p) => p.id == projectId);
      return project.name;
    } catch (e) {
      return 'Unknown Project';
    }
  }

  /// Get project by ID
  ProjectModel? getProjectById(String projectId) {
    try {
      return projectsList.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  /// Get client name by project ID
  String getClientNameByProjectId(String projectId) {
    try {
      final project = projectsList.firstWhere((p) => p.id == projectId);
      final client = clientsList.firstWhere((c) => c.id == project.clientId);
      return client.name;
    } catch (e) {
      return 'Unknown Client';
    }
  }

  /// Delete an invoice
  Future<void> deleteInvoice(String id) async {
    try {
      final invoice = invoicesList.firstWhere((i) => i.id == id);

      // Show confirmation dialog
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Invoice'),
          content: Text(
            'Are you sure you want to delete invoice #${invoice.invoiceNumber}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Haptic feedback for delete action
      HapticFeedback.mediumImpact();

      await _storageService.deleteInvoice(id);
      invoicesList.removeWhere((invoice) => invoice.id == id);

      Get.snackbar(
        'Success',
        'Invoice deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Haptic feedback for error
      HapticFeedback.heavyImpact();

      Get.snackbar(
        'Error',
        'Failed to delete invoice',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Refresh invoices list
  Future<void> refreshInvoices() async {
    await loadInvoices();
  }

  /// Navigate to add invoice
  void navigateToAddInvoice() {
    Get.to(
      () => const AddInvoiceView(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    )?.then((_) => loadInvoices());
  }

  /// Navigate to invoice details
  void navigateToInvoiceDetails(InvoiceModel invoice) {
    // Details view not implemented yet, show snackbar
    Get.snackbar(
      'Invoice Details',
      'Invoice #${invoice.invoiceNumber}\nAmount: \$${invoice.amount.toStringAsFixed(2)}\nStatus: ${invoice.status}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// Navigate to edit invoice
  void navigateToEditInvoice(InvoiceModel invoice) {
    Get.to(
      () => const EditInvoiceView(),
      arguments: invoice,
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    )?.then((_) => loadInvoices());
  }
}
