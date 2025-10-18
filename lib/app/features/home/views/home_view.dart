// TODO: Implement Home View
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/home_controller.dart';

// class HomeView extends GetView<HomeController> {
//   const HomeView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Budget Tracker'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () => Get.toNamed('/settings'),
//           ),
//         ],
//       ),
//       body: Obx(() => ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Dashboard cards showing total budget, received, remaining
//           // Quick access to clients, projects, invoices
//         ],
//       )),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Show add menu
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
