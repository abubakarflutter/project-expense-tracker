import 'package:get/get.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/services/storage_service.dart';

class HomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Observable variables
  final totalBudget = 0.0.obs;
  final totalReceived = 0.0.obs;
  final totalRemaining = 0.0.obs;
  final recentProjects = <ProjectModel>[].obs;
  final allProjects = <ProjectModel>[].obs;
  final clients = <ClientModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Load all data from storage
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // Load clients and projects
      clients.value = _storageService.getClients();
      final loadedProjects = _storageService.getProjects();
      allProjects.value = loadedProjects;

      // Calculate totals
      calculateTotals(loadedProjects);

      // Get 5 most recent projects (sorted by createdAt descending)
      recentProjects.value = _getMostRecentProjects(loadedProjects, 5);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate total budget, received, and remaining from all projects
  void calculateTotals(List<ProjectModel> projects) {
    totalBudget.value = _storageService.getTotalBudgetAmount();
    totalReceived.value = _storageService.getTotalReceivedAmount();
    totalRemaining.value = _storageService.getTotalRemainingAmount();
  }

  /// Get the N most recent projects
  List<ProjectModel> _getMostRecentProjects(
      List<ProjectModel> projects, int count) {
    if (projects.isEmpty) return [];

    // Sort by createdAt descending (most recent first)
    final sortedProjects = List<ProjectModel>.from(projects)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Return top N projects
    return sortedProjects.take(count).toList();
  }

  /// Get client name by ID
  String getClientName(String clientId) {
    try {
      final client = clients.firstWhere((c) => c.id == clientId);
      return client.name;
    } catch (e) {
      return 'Unknown Client';
    }
  }

  /// Refresh dashboard data
  Future<void> refreshData() async {
    await loadData();
  }

  /// Get summary statistics
  int get totalProjectsCount => allProjects.length;
  int get totalClientsCount => clients.length;
  int get totalInvoicesCount => _storageService.getInvoices().length;

  /// Get active projects count
  int get activeProjectsCount {
    return allProjects
        .where((p) => p.status.toLowerCase() == 'active')
        .length;
  }

  /// Get completed projects count
  int get completedProjectsCount {
    return allProjects
        .where((p) => p.status.toLowerCase() == 'completed')
        .length;
  }
}
