import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/client_model.dart';
import '../../../data/services/storage_service.dart';
import '../views/add_client_view.dart';
import '../views/edit_client_view.dart';

class ClientsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Observable variables
  final clientsList = <ClientModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  /// Load all clients from storage
  Future<void> loadClients() async {
    try {
      isLoading.value = true;
      clientsList.value = _storageService.getClients();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load clients',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered clients based on search query
  List<ClientModel> get filteredClients {
    if (searchQuery.value.isEmpty) {
      return clientsList;
    }
    final query = searchQuery.value.toLowerCase();
    return clientsList.where((client) {
      return client.name.toLowerCase().contains(query) ||
          client.email.toLowerCase().contains(query) ||
          (client.company?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Get number of projects for a client
  int getProjectsCount(String clientId) {
    return _storageService.getProjectsByClientId(clientId).length;
  }

  /// Delete a client
  Future<void> deleteClient(String id) async {
    try {
      // Check if client has projects
      final projectsCount = getProjectsCount(id);
      if (projectsCount > 0) {
        // Show confirmation dialog
        final confirm = await Get.dialog<bool>(
          _buildDeleteConfirmationDialog(projectsCount),
        );

        if (confirm != true) return;
      }

      // Haptic feedback for delete action
      HapticFeedback.mediumImpact();

      await _storageService.deleteClient(id);
      clientsList.removeWhere((client) => client.id == id);

      Get.snackbar(
        'Success',
        'Client deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Haptic feedback for error
      HapticFeedback.heavyImpact();

      Get.snackbar(
        'Error',
        'Failed to delete client',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Refresh clients list
  Future<void> refreshClients() async {
    await loadClients();
  }

  /// Navigate to add client
  void navigateToAddClient() {
    Get.to(
      () => const AddClientView(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    )?.then((_) => loadClients());
  }

  /// Navigate to edit client
  void navigateToEditClient(ClientModel client) {
    Get.to(
      () => const EditClientView(),
      arguments: client,
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    )?.then((_) => loadClients());
  }

  Widget _buildDeleteConfirmationDialog(int projectsCount) {
    return AlertDialog(
      title: const Text('Delete Client'),
      content: Text(
        'This client has $projectsCount project(s). Deleting this client will also delete all associated projects and invoices. Are you sure?',
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
    );
  }
}
