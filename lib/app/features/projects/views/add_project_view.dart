import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/add_project_controller.dart';

class AddProjectView extends StatelessWidget {
  const AddProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddProjectController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: controller.clearFields,
            child: const Text('Clear'),
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
                          PhosphorIconsRegular.folderStar,
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
                              'New Project',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Fill in the project details',
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

              // Project Information Section
              Text(
                'Project Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),

              const SizedBox(height: 16),

              // Project name field
              CustomTextField(
                controller: controller.nameController,
                label: 'Project Name',
                hint: 'Enter project name',
                prefixIcon: const Icon(PhosphorIconsRegular.folder),
                validator: controller.validateName,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // Client dropdown
              Obx(() {
                final clients = controller.clientsList;

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Client',
                    hintText: 'Select a client',
                    prefixIcon: const Icon(PhosphorIconsRegular.user),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a client';
                    }
                    return null;
                  },
                  items: clients.map((client) {
                    return DropdownMenuItem<String>(
                      value: client.id,
                      child: Text(client.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final client = clients.firstWhere((c) => c.id == value);
                      controller.setSelectedClient(client);
                    }
                  },
                );
              }),

              const SizedBox(height: 16),

              // Total budget field
              CurrencyTextField(
                controller: controller.totalBudgetController,
                label: 'Total Budget',
                hint: 'Enter total budget',
                validator: controller.validateBudget,
              ),

              const SizedBox(height: 16),

              // Status dropdown
              DropdownButtonFormField<String>(
                initialValue: controller.selectedStatus.value,
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
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.setSelectedStatus(value);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Description field
              MultilineTextField(
                controller: controller.descriptionController,
                label: 'Description (Optional)',
                hint: 'Enter project description',
                maxLines: 4,
                minLines: 3,
              ),

              const SizedBox(height: 24),

              // Dates Section
              Text(
                'Project Timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),

              const SizedBox(height: 16),

              // Start date picker
              Obx(() {
                final startDateValue = controller.startDate.value;
                final dateFormat = DateFormat('MMM dd, yyyy');

                return InkWell(
                  onTap: () => controller.pickStartDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date (Optional)',
                      hintText: 'Select start date',
                      prefixIcon: const Icon(PhosphorIconsRegular.calendar),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      startDateValue != null
                          ? dateFormat.format(startDateValue)
                          : 'Select start date',
                      style: TextStyle(
                        color: startDateValue != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // End date picker
              Obx(() {
                final endDateValue = controller.endDate.value;
                final dateFormat = DateFormat('MMM dd, yyyy');

                return InkWell(
                  onTap: () => controller.pickEndDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End Date (Optional)',
                      hintText: 'Select end date',
                      prefixIcon: const Icon(PhosphorIconsRegular.calendar),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      endDateValue != null
                          ? dateFormat.format(endDateValue)
                          : 'Select end date',
                      style: TextStyle(
                        color: endDateValue != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Save button
              Obx(() => CustomButton(
                    text: 'Add Project',
                    onPressed: controller.saveProject,
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
