// TODO: Implement Projects View
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/projects_controller.dart';

// class ProjectsView extends GetView<ProjectsController> {
//   const ProjectsView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Projects'),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (controller.projects.isEmpty) {
//           return const Center(
//             child: Text('No projects yet. Add your first project!'),
//           );
//         }
//
//         return ListView.builder(
//           itemCount: controller.projects.length,
//           itemBuilder: (context, index) {
//             final project = controller.projects[index];
//             return ListTile(
//               title: Text(project.name),
//               subtitle: Text('Budget: \$${project.totalBudget}'),
//               trailing: Chip(label: Text(project.status)),
//               onTap: () {
//                 // Navigate to project details
//               },
//             );
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Show add project dialog
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
