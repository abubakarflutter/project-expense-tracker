import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../controllers/edit_invoice_controller.dart';

class EditInvoiceView extends StatelessWidget {
  const EditInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditInvoiceController());

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Edit Invoice',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: controller.resetFields,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header section
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.receipt,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Invoice',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Update invoice details',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Invoice Information Section
              Text(
                'Invoice Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),

              const SizedBox(height: 16),

              // Invoice number field
              CustomTextField(
                controller: controller.invoiceNumberController,
                label: 'Invoice Number',
                hint: 'Invoice number',
                prefixIcon: const Icon(PhosphorIconsRegular.tag),
                validator: controller.validateInvoiceNumber,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // Project dropdown
              Obx(() {
                final projects = controller.projectsList;

                return DropdownButtonFormField<String>(
                  value: controller.selectedProject.value?.id,
                  decoration: InputDecoration(
                    labelText: 'Project',
                    hintText: 'Select a project',
                    prefixIcon: const Icon(PhosphorIconsRegular.folder),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a project';
                    }
                    return null;
                  },
                  items: projects.map((project) {
                    final clientName = controller.getClientName(project.clientId);
                    return DropdownMenuItem<String>(
                      value: project.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            clientName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final project = projects.firstWhere((p) => p.id == value);
                      controller.setSelectedProject(project);
                    }
                  },
                );
              }),

              const SizedBox(height: 16),

              // Amount field
              CurrencyTextField(
                controller: controller.amountController,
                label: 'Amount',
                hint: 'Enter invoice amount',
                validator: controller.validateAmount,
              ),

              const SizedBox(height: 16),

              // Payment date picker
              Obx(() {
                final paymentDateValue = controller.paymentDate.value;
                final dateFormat = DateFormat('MMM dd, yyyy');

                return InkWell(
                  onTap: () => controller.pickPaymentDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Payment Date',
                      hintText: 'Select payment date',
                      prefixIcon: const Icon(PhosphorIconsRegular.calendar),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      paymentDateValue != null
                          ? dateFormat.format(paymentDateValue)
                          : 'Select payment date',
                      style: TextStyle(
                        color: paymentDateValue != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Payment Details Section
              Text(
                'Payment Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),

              const SizedBox(height: 16),

              // Payment method dropdown
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedPaymentMethod.value,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: const Icon(PhosphorIconsRegular.creditCard),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: controller.paymentMethodOptions.map((method) {
                      return DropdownMenuItem<String>(
                        value: method['value'],
                        child: Text(method['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setSelectedPaymentMethod(value);
                      }
                    },
                  )),

              const SizedBox(height: 16),

              // Status dropdown
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedStatus.value,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: const Icon(PhosphorIconsRegular.info),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: controller.statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: status == 'Paid'
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(status),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setSelectedStatus(value);
                      }
                    },
                  )),

              const SizedBox(height: 16),

              // Description field
              MultilineTextField(
                controller: controller.descriptionController,
                label: 'Description',
                hint: 'Enter invoice description',
                maxLines: 4,
                minLines: 3,
                validator: controller.validateDescription,
              ),

              const SizedBox(height: 32),

              // Update button
              Obx(() => CustomButton(
                    text: 'Update Invoice',
                    onPressed: controller.updateInvoice,
                    isLoading: controller.isLoading.value,
                    icon: PhosphorIconsRegular.check,
                  )),

              const SizedBox(height: 16),

              // Cancel button
              CustomButton(
                text: 'Cancel',
                onPressed: () => Get.back(),
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
