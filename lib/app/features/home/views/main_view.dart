import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../clients/views/clients_page.dart';
import '../../invoices/views/invoices_page.dart';
import '../../projects/views/projects_page.dart';
import '../../settings/views/settings_page.dart';
import '../controllers/main_controller.dart';
import 'home_page.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  // List of pages
  static const List<Widget> _pages = [
    HomePage(),
    ProjectsPage(),
    ClientsPage(),
    InvoicesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          )),
      bottomNavigationBar: Obx(() => _buildBottomNavigationBar(context, controller)),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, MainController controller) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.house),
            activeIcon: Icon(PhosphorIconsFill.house),
            label: 'Home',
            tooltip: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.folder),
            activeIcon: Icon(PhosphorIconsFill.folder),
            label: 'Projects',
            tooltip: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.users),
            activeIcon: Icon(PhosphorIconsFill.users),
            label: 'Clients',
            tooltip: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.receipt),
            activeIcon: Icon(PhosphorIconsFill.receipt),
            label: 'Invoices',
            tooltip: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.gear),
            activeIcon: Icon(PhosphorIconsFill.gear),
            label: 'Settings',
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}
