import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../controllers/edit_client_controller.dart';

class EditClientView extends StatelessWidget {
  const EditClientView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditClientController());

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Edit Client',
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
                          PhosphorIconsRegular.pencilSimple,
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
                              'Edit Client',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Update client details',
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

              // Client Information Section
              Text(
                'Client Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),

              const SizedBox(height: 16),

              // Name field
              CustomTextField(
                controller: controller.nameController,
                label: 'Client Name',
                hint: 'Enter client name',
                prefixIcon: const Icon(PhosphorIconsRegular.user),
                validator: controller.validateName,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // Company field (optional)
              CustomTextField(
                controller: controller.companyController,
                label: 'Company (Optional)',
                hint: 'Enter company name',
                prefixIcon: const Icon(PhosphorIconsRegular.briefcase),
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 24),

              // Contact Information Section
              Text(
                'Contact Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),

              const SizedBox(height: 16),

              // Email field
              EmailTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'Enter email address',
                validator: controller.validateEmail,
              ),

              const SizedBox(height: 16),

              // Phone field
              PhoneTextField(
                controller: controller.phoneController,
                label: 'Phone',
                hint: 'Enter phone number',
                validator: controller.validatePhone,
              ),

              const SizedBox(height: 32),

              // Update button
              Obx(() => CustomButton(
                    text: 'Update Client',
                    onPressed: controller.updateClient,
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
