// TODO: Implement Invoices View
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/invoices_controller.dart';

// class InvoicesView extends GetView<InvoicesController> {
//   const InvoicesView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Invoices'),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (controller.invoices.isEmpty) {
//           return const Center(
//             child: Text('No invoices yet. Add your first invoice!'),
//           );
//         }
//
//         return ListView.builder(
//           itemCount: controller.invoices.length,
//           itemBuilder: (context, index) {
//             final invoice = controller.invoices[index];
//             return ListTile(
//               title: Text(invoice.milestoneName),
//               subtitle: Text('Amount: \$${invoice.amount}'),
//               trailing: Chip(
//                 label: Text(invoice.status),
//                 backgroundColor: invoice.status == 'paid'
//                     ? Colors.green
//                     : Colors.orange,
//               ),
//               onTap: () {
//                 // Navigate to invoice details
//               },
//             );
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Show add invoice dialog
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
