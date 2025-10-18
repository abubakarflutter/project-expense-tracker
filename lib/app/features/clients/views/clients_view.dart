// TODO: Implement Clients View
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/clients_controller.dart';

// class ClientsView extends GetView<ClientsController> {
//   const ClientsView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Clients'),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (controller.clients.isEmpty) {
//           return const Center(
//             child: Text('No clients yet. Add your first client!'),
//           );
//         }
//
//         return ListView.builder(
//           itemCount: controller.clients.length,
//           itemBuilder: (context, index) {
//             final client = controller.clients[index];
//             return ListTile(
//               title: Text(client.name),
//               subtitle: Text(client.email),
//               onTap: () {
//                 // Navigate to client details
//               },
//             );
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Show add client dialog
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
