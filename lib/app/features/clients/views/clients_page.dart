import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expandable/expandable.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/gradient_fab.dart';
import '../controllers/clients_controller.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientsController());

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Clients',
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
            onPressed: controller.refreshClients,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search clients...',
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

          // Clients list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.clientsList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.clientsList.isEmpty) {
                return _buildEmptyState(controller);
              }

              final filteredClients = controller.filteredClients;

              if (filteredClients.isEmpty) {
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
                        'No clients found',
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

              return RefreshIndicator(
                onRefresh: controller.refreshClients,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    final projectsCount = controller.getProjectsCount(client.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildClientCard(client, projectsCount, controller),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: GradientFAB(
        heroTag: 'clients_fab',
        onPressed: controller.navigateToAddClient,
        icon: PhosphorIconsRegular.plus,
        label: 'Add Client',
      ),
    );
  }

  Widget _buildClientCard(
    client,
    int projectsCount,
    ClientsController controller,
  ) {
    return ExpandableNotifier(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
        child: Expandable(
          collapsed: ExpandableButton(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon with gradient background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.user,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Client info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (client.company != null && client.company!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            client.company!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Projects count badge
                  if (projectsCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.successGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$projectsCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Expand icon
                  Icon(
                    PhosphorIconsRegular.caretDown,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          expanded: ExpandableButton(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.user,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (client.company != null && client.company!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                client.company!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Collapse icon
                      Icon(
                        PhosphorIconsRegular.caretUp,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  // Contact info
                  Row(
                    children: [
                      const Icon(
                        PhosphorIconsRegular.envelope,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          client.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        PhosphorIconsRegular.phone,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        client.phone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (projectsCount > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          PhosphorIconsRegular.folder,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$projectsCount ${projectsCount == 1 ? 'project' : 'projects'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => controller.navigateToEditClient(client),
                        icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => controller.deleteClient(client.id),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ClientsController controller) {
    return Center(
      child: EmptyStateCard(
        icon: PhosphorIconsRegular.users,
        title: 'No Clients Yet',
        message: 'Add your first client to start tracking projects',
        actionText: 'Add Client',
        onAction: controller.navigateToAddClient,
      ),
    );
  }
}
