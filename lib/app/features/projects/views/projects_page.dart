import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../controllers/projects_controller.dart';

// Helper function to capitalize strings
String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProjectsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
            onPressed: controller.refreshProjects,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Obx(() => TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search projects...',
                    prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass),
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(PhosphorIconsRegular.x),
                            onPressed: controller.clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                )),
          ),

          // Filter chips and sort dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Filter chips
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() => Row(
                          children: controller.filterOptions.map((filter) {
                            final isSelected = controller.selectedFilter.value == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  _capitalize(filter),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    controller.setFilter(filter);
                                  }
                                },
                                backgroundColor: Colors.grey.shade200,
                                selectedColor: AppTheme.primaryColor,
                                checkmarkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                  ),
                ),

                const SizedBox(width: 8),

                // Sort dropdown
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: controller.sortOption.value,
                        underline: const SizedBox(),
                        icon: const Icon(PhosphorIconsRegular.sortAscending, size: 20),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        items: controller.sortOptions.map((option) {
                          String label;
                          switch (option) {
                            case 'name':
                              label = 'Name';
                              break;
                            case 'date':
                              label = 'Date';
                              break;
                            case 'budget':
                              label = 'Budget';
                              break;
                            default:
                              label = option;
                          }
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.setSortOption(value);
                          }
                        },
                      ),
                    )),
              ],
            ),
          ),

          // Projects list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.projectsList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final filteredProjects = controller.filteredProjects;

              if (filteredProjects.isEmpty) {
                // Check if it's due to search with no results
                if (controller.searchQuery.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIconsRegular.magnifyingGlassMinus,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No projects found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _buildEmptyState(controller);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshProjects,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    final clientName = controller.getClientName(project.clientId);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildProjectCard(
                        project,
                        clientName,
                        controller,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'projects_fab',
        onPressed: controller.navigateToAddProject,
        icon: const Icon(PhosphorIconsRegular.plus),
        label: const Text('Add Project'),
      ),
    );
  }

  Widget _buildProjectCard(
    project,
    String clientName,
    ProjectsController controller,
  ) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    // Calculate progress percentage
    final progress = project.totalBudget > 0
        ? (project.totalReceived / project.totalBudget).clamp(0.0, 1.0)
        : 0.0;

    // Status color
    Color statusColor;
    switch (project.status.toLowerCase()) {
      case 'active':
        statusColor = AppTheme.successColor;
        break;
      case 'completed':
        statusColor = AppTheme.primaryColor;
        break;
      case 'on-hold':
        statusColor = AppTheme.warningColor;
        break;
      default:
        statusColor = AppTheme.textSecondary;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              PhosphorIconsRegular.user,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              clientName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status badge with gradient
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: project.status.toLowerCase() == 'active'
                          ? AppTheme.successGradient
                          : project.status.toLowerCase() == 'completed'
                              ? AppTheme.primaryGradient
                              : AppTheme.warningGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _capitalize(project.status),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Budget information
              Row(
                children: [
                  Expanded(
                    child: _buildBudgetItem(
                      'Total Budget',
                      currencyFormatter.format(project.totalBudget),
                      AppTheme.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: _buildBudgetItem(
                      'Received',
                      currencyFormatter.format(project.totalReceived),
                      AppTheme.successColor,
                    ),
                  ),
                  Expanded(
                    child: _buildBudgetItem(
                      'Remaining',
                      currencyFormatter.format(project.remainingBudget),
                      AppTheme.warningColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => controller.navigateToProjectDetails(project),
                    icon: const Icon(PhosphorIconsRegular.eye, size: 18),
                    label: const Text('View'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentColor,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => controller.navigateToEditProject(project),
                        icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: () => controller.deleteProject(project.id),
                        icon: const Icon(PhosphorIconsRegular.trash, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetItem(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ProjectsController controller) {
    return Center(
      child: EmptyStateCard(
        icon: PhosphorIconsRegular.folderOpen,
        title: 'No Projects Yet',
        message: controller.selectedFilter.value == 'all'
            ? 'Start by adding your first project'
            : 'No ${controller.selectedFilter.value} projects found',
        actionText: 'Add Project',
        onAction: controller.navigateToAddProject,
      ),
    );
  }
}
