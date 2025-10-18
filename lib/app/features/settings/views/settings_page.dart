import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../data/services/storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Settings',
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // App Settings Section
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Currency Format (Coming Soon)
          _buildSettingTile(
            icon: PhosphorIconsRegular.currencyCircleDollar,
            title: 'Currency Format',
            subtitle: 'USD (\$)',
            trailing: const Chip(
              label: Text(
                'Coming Soon',
                style: TextStyle(fontSize: 10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
            onTap: () {
              Get.snackbar(
                'Coming Soon',
                'Currency format customization will be available in a future update',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),

          const SizedBox(height: 24),

          // Data Management Section
          const Text(
            'Data Management',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Export Data (Coming Soon)
          _buildSettingTile(
            icon: PhosphorIconsRegular.downloadSimple,
            title: 'Export Data',
            subtitle: 'Export all data to JSON file',
            trailing: const Chip(
              label: Text(
                'Coming Soon',
                style: TextStyle(fontSize: 10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
            onTap: () {
              Get.snackbar(
                'Coming Soon',
                'Data export feature will be available in a future update',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),

          const SizedBox(height: 8),

          // Clear All Data
          _buildSettingTile(
            icon: PhosphorIconsRegular.trash,
            iconColor: Colors.red,
            title: 'Clear All Data',
            subtitle: 'Delete all clients, projects, and invoices',
            onTap: _showClearDataDialog,
          ),

          const SizedBox(height: 24),

          // About Section
          const Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // About App
          _buildSettingTile(
            icon: PhosphorIconsRegular.info,
            title: 'About Budget Tracker',
            subtitle: 'Version $_appVersion',
            onTap: _showAboutDialog,
          ),

          const SizedBox(height: 32),

          // App Info Footer
          Center(
            child: Column(
              children: [
                Icon(
                  PhosphorIconsRegular.wallet,
                  size: 48,
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                Text(
                  'Budget Tracker',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage clients, projects & invoices',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: trailing ??
            const Icon(
              PhosphorIconsRegular.caretRight,
              color: AppTheme.textSecondary,
            ),
      ),
    );
  }

  void _showClearDataDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(PhosphorIconsRegular.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all data? This will permanently remove all clients, projects, and invoices. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await _clearAllData();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      final storageService = Get.find<StorageService>();
      await storageService.clearAllData();

      Get.snackbar(
        'Success',
        'All data has been cleared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Budget Tracker',
      applicationVersion: _appVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          PhosphorIconsRegular.wallet,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'A comprehensive budget tracking application for managing clients, projects, and invoices.',
        ),
        const SizedBox(height: 8),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Client Management'),
        const Text('• Project Tracking'),
        const Text('• Invoice Management'),
        const Text('• Budget Monitoring'),
        const Text('• Payment Tracking'),
      ],
    );
  }
}
