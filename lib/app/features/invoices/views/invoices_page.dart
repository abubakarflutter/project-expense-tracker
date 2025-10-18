import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expandable/expandable.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/gradient_fab.dart';
import '../controllers/invoices_controller.dart';

// Helper function to capitalize strings
String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InvoicesController());

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Invoices',
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
            onPressed: controller.refreshInvoices,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Invoices list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.invoicesList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final filteredInvoices = controller.filteredInvoices;

              if (filteredInvoices.isEmpty) {
                return _buildEmptyState(controller);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshInvoices,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = filteredInvoices[index];
                    final projectName = controller.getProjectName(invoice.projectId);
                    final clientName = controller.getClientNameByProjectId(invoice.projectId);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildInvoiceCard(
                        invoice,
                        projectName,
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
      floatingActionButton: GradientFAB(
        heroTag: 'invoices_fab',
        onPressed: controller.navigateToAddInvoice,
        icon: PhosphorIconsRegular.plus,
        label: 'Add Invoice',
      ),
    );
  }

  Widget _buildInvoiceCard(
    invoice,
    String projectName,
    String clientName,
    InvoicesController controller,
  ) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('MMM dd, yyyy');

    // Status color
    final isPaid = invoice.status.toLowerCase() == 'paid';
    final statusColor = isPaid ? AppTheme.successColor : AppTheme.warningColor;

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
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: isPaid ? AppTheme.successGradient : AppTheme.warningGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _capitalize(invoice.status),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                  // Header
                  Row(
                    children: [
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
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: isPaid ? AppTheme.successGradient : AppTheme.warningGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _capitalize(invoice.status),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
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
                  // Project and client info
                  Row(
                    children: [
                      const Icon(
                        PhosphorIconsRegular.folder,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          projectName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
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
                      const SizedBox(width: 10),
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        PhosphorIconsRegular.creditCard,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        invoice.formattedPaymentMethod,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => controller.navigateToEditInvoice(invoice),
                        icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => controller.deleteInvoice(invoice.id),
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

  Widget _buildEmptyState(InvoicesController controller) {
    return Center(
      child: EmptyStateCard(
        icon: PhosphorIconsRegular.receiptX,
        title: 'No Invoices Yet',
        message: controller.selectedFilter.value == 'all'
            ? 'Start by adding your first invoice'
            : 'No ${controller.selectedFilter.value} invoices found',
        actionText: 'Add Invoice',
        onAction: controller.navigateToAddInvoice,
      ),
    );
  }
}
