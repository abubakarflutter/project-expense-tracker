import 'package:flutter/material.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart' hide SummaryCard;
import '../controllers/home_controller.dart';
import '../widgets/budget_chart.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create controller if not already created
    final controller = Get.put(HomeController());

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
            onPressed: controller.refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.recentProjects.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Large Summary Card - Total Remaining (Most Important)
              Obx(
                () => SummaryCard(
                  title: 'Total Remaining',
                  amount: controller.totalRemaining.value,
                  icon: PhosphorIconsRegular.wallet,
                  color: AppTheme.warningColor,
                  isLarge: true,
                ),
              ),

              const SizedBox(height: 22),

              // Summary Cards Grid
              Row(
                children: [
                  // Total Received
                  Expanded(
                    child: Obx(
                      () => SummaryCard(
                        title: 'Received',
                        amount: controller.totalReceived.value,
                        icon: PhosphorIconsRegular.arrowDown,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Total Budget
                  Expanded(
                    child: Obx(
                      () => SummaryCard(
                        title: 'Total Budget',
                        amount: controller.totalBudget.value,
                        icon: PhosphorIconsRegular.currencyCircleDollar,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Budget Chart
              Obx(
                () => BudgetChart(
                  totalBudget: controller.totalBudget.value,
                  totalReceived: controller.totalReceived.value,
                  totalRemaining: controller.totalRemaining.value,
                ),
              ),

              const SizedBox(height: 24),

              // Quick Stats
              _buildQuickStats(controller),

              const SizedBox(height: 24),

              // Recent Projects Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Projects',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (controller.recentProjects.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Navigate to projects page
                        // TODO: Implement navigation to projects page
                      },
                      child: const Text('View All'),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Recent Projects List
              Obx(() {
                if (controller.recentProjects.isEmpty) {
                  return _buildEmptyState(context);
                }

                return Column(
                  children: controller.recentProjects.map((project) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProjectCard(
                        name: project.name,
                        clientName: controller.getClientName(project.clientId),
                        budget: project.totalBudget,
                        received: project.totalReceived,
                        status: project.status,
                        onTap: () {
                          // Navigate to project details
                        },
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuickStats(HomeController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    PhosphorIconsRegular.folder,
                    '${controller.totalProjectsCount}',
                    'Projects',
                    AppTheme.primaryColor,
                  ),
                  _buildStatItem(
                    PhosphorIconsRegular.users,
                    '${controller.totalClientsCount}',
                    'Clients',
                    AppTheme.accentColor,
                  ),
                  _buildStatItem(
                    PhosphorIconsRegular.receipt,
                    '${controller.totalInvoicesCount}',
                    'Invoices',
                    AppTheme.warningColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateCard(
      icon: PhosphorIconsRegular.folderOpen,
      title: 'No Projects Yet',
      message: 'Start by adding your first client and project',
      actionText: 'Add Project',
      onAction: () {
        // Navigate to add project
      },
    );
  }
}
