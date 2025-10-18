import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/services/storage_service.dart';
import '../views/add_project_view.dart';
import '../views/project_detail_view.dart';

class ProjectsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Observable variables
  final projectsList = <ProjectModel>[].obs;
  final clientsList = <ClientModel>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs;
  final searchQuery = ''.obs;
  final sortOption = 'name'.obs;

  // Filter options
  final List<String> filterOptions = ['all', 'active', 'completed', 'on-hold'];

  // Sort options
  final List<String> sortOptions = ['name', 'date', 'budget'];

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  /// Load all projects and clients from storage
  Future<void> loadProjects() async {
    try {
      isLoading.value = true;
      clientsList.value = _storageService.getClients();
      projectsList.value = _storageService.getProjects();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load projects',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered and sorted projects based on selected filter, search query, and sort option
  List<ProjectModel> get filteredProjects {
    // First filter by status
    var filtered = selectedFilter.value == 'all'
        ? projectsList.toList()
        : projectsList
            .where((project) =>
                project.status.toLowerCase() == selectedFilter.value.toLowerCase())
            .toList();

    // Then filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((project) {
        final clientName = getClientName(project.clientId).toLowerCase();
        return project.name.toLowerCase().contains(query) ||
            clientName.contains(query) ||
            (project.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Finally sort by selected option
    switch (sortOption.value) {
      case 'name':
        filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'date':
        filtered.sort((a, b) {
          final aDate = a.startDate ?? a.createdAt;
          final bDate = b.startDate ?? b.createdAt;
          return bDate.compareTo(aDate); // Most recent first
        });
        break;
      case 'budget':
        filtered.sort((a, b) => b.totalBudget.compareTo(a.totalBudget)); // Highest first
        break;
    }

    return filtered;
  }

  /// Set the selected filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// Set the selected sort option
  void setSortOption(String sort) {
    sortOption.value = sort;
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Get client name by ID
  String getClientName(String clientId) {
    try {
      final client = clientsList.firstWhere((c) => c.id == clientId);
      return client.name;
    } catch (e) {
      return 'Unknown Client';
    }
  }

  /// Get client by ID
  ClientModel? getClientById(String clientId) {
    try {
      return clientsList.firstWhere((c) => c.id == clientId);
    } catch (e) {
      return null;
    }
  }

  /// Delete a project
  Future<void> deleteProject(String id) async {
    try {
      // Check if project has invoices
      final invoicesCount = _storageService.getInvoicesByProjectId(id).length;
      if (invoicesCount > 0) {
        // Show confirmation dialog
        final confirm = await Get.dialog<bool>(
          _buildDeleteConfirmationDialog(invoicesCount),
        );

        if (confirm != true) return;
      }

      // Haptic feedback for delete action
      HapticFeedback.mediumImpact();

      await _storageService.deleteProject(id);
      projectsList.removeWhere((project) => project.id == id);

      Get.snackbar(
        'Success',
        'Project deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Haptic feedback for error
      HapticFeedback.heavyImpact();

      Get.snackbar(
        'Error',
        'Failed to delete project',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Refresh projects list
  Future<void> refreshProjects() async {
    await loadProjects();
  }

  /// Navigate to add project
  void navigateToAddProject() {
    Get.to(
      () => const AddProjectView(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    )?.then((_) => loadProjects());
  }

  /// Navigate to project details
  void navigateToProjectDetails(ProjectModel project) {
    Get.to(
      () => const ProjectDetailView(),
      arguments: project,
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    )?.then((_) => loadProjects());
  }

  /// Navigate to edit project
  void navigateToEditProject(ProjectModel project) {
    // For now, navigate to add project (edit not implemented yet)
    Get.to(
      () => const AddProjectView(),
      arguments: project,
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    )?.then((_) => loadProjects());
  }

  /// Get invoices count for a project
  int getInvoicesCount(String projectId) {
    return _storageService.getInvoicesByProjectId(projectId).length;
  }

  Widget _buildDeleteConfirmationDialog(int invoicesCount) {
    return AlertDialog(
      title: const Text('Delete Project'),
      content: Text(
        'This project has $invoicesCount invoice(s). Deleting this project will also delete all associated invoices. Are you sure?',
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
