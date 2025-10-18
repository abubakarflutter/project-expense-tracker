import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/services/storage_service.dart';
import '../../invoices/views/add_invoice_view.dart';

// Helper function to capitalize strings
String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

class ProjectDetailView extends StatelessWidget {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final StorageService storageService = Get.find<StorageService>();
    final project = Get.arguments as ProjectModel;
    final invoices = storageService.getInvoicesByProjectId(project.id).obs;
    final client = storageService.getClientById(project.clientId);

    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('MMM dd, yyyy');

    // Calculate progress
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

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Project Details',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.pencilSimple),
            onPressed: () {
              // Edit not implemented yet
              Get.snackbar(
                'Coming Soon',
                'Project editing will be available in a future update',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.trash),
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Delete Project'),
                  content: const Text(
                    'Are you sure you want to delete this project? This will also delete all associated invoices.',
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

              if (confirm == true) {
                await storageService.deleteProject(project.id);
                Get.back(result: true);
                Get.snackbar(
                  'Success',
                  'Project deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            tooltip: 'Delete',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Project Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _capitalize(project.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        PhosphorIconsRegular.user,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        client?.name ?? 'Unknown Client',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (project.description != null &&
                      project.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Budget Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Budget Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBudgetSummaryItem(
                          'Total Budget',
                          currencyFormatter.format(project.totalBudget),
                          AppTheme.primaryColor,
                          PhosphorIconsRegular.currencyCircleDollar,
                        ),
                      ),
                      Expanded(
                        child: _buildBudgetSummaryItem(
                          'Received',
                          currencyFormatter.format(project.totalReceived),
                          AppTheme.successColor,
                          PhosphorIconsRegular.arrowDown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBudgetSummaryItem(
                          'Remaining',
                          currencyFormatter.format(project.remainingBudget),
                          AppTheme.warningColor,
                          PhosphorIconsRegular.wallet,
                        ),
                      ),
                      Expanded(
                        child: _buildBudgetSummaryItem(
                          'Progress',
                          '${(progress * 100).toStringAsFixed(0)}%',
                          statusColor,
                          PhosphorIconsRegular.trendUp,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Timeline Card (if dates are available)
          if (project.startDate != null || project.endDate != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timeline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (project.startDate != null)
                      _buildTimelineItem(
                        'Start Date',
                        dateFormatter.format(project.startDate!),
                        PhosphorIconsRegular.playCircle,
                      ),
                    if (project.startDate != null && project.endDate != null)
                      const SizedBox(height: 12),
                    if (project.endDate != null)
                      _buildTimelineItem(
                        'End Date',
                        dateFormatter.format(project.endDate!),
                        PhosphorIconsRegular.stopCircle,
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Invoices Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invoices (${invoices.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to add invoice
                  Get.to(
                    () => const AddInvoiceView(),
                    arguments: project,
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                icon: const Icon(PhosphorIconsRegular.plus),
                label: const Text('Add Invoice'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Invoices List
          Obx(() {
            if (invoices.isEmpty) {
              return Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        PhosphorIconsRegular.receiptX,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No invoices yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add your first invoice to track payments',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: invoices.map((invoice) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildInvoiceCard(invoice, currencyFormatter, dateFormatter),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBudgetSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(
    InvoiceModel invoice,
    NumberFormat currencyFormatter,
    DateFormat dateFormatter,
  ) {
    final isPaid = invoice.status.toLowerCase() == 'paid';
    final statusColor = isPaid ? AppTheme.successColor : AppTheme.warningColor;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Show invoice details
          Get.snackbar(
            'Invoice Details',
            'Invoice #${invoice.invoiceNumber}\nAmount: ${currencyFormatter.format(invoice.amount)}\nStatus: ${invoice.status}',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  PhosphorIconsRegular.receipt,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice #${invoice.invoiceNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatter.format(invoice.paymentDate),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormatter.format(invoice.amount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _capitalize(invoice.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
