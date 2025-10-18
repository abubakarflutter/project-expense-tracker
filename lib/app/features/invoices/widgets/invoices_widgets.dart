// TODO: Add invoices-specific widgets here
// import 'package:flutter/material.dart';

// class InvoiceCard extends StatelessWidget {
//   final String milestoneName;
//   final double amount;
//   final String dueDate;
//   final String status;
//   final VoidCallback onTap;
//   final VoidCallback? onMarkAsPaid;
//
//   const InvoiceCard({
//     Key? key,
//     required this.milestoneName,
//     required this.amount,
//     required this.dueDate,
//     required this.status,
//     required this.onTap,
//     this.onMarkAsPaid,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     milestoneName,
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   Chip(
//                     label: Text(status),
//                     backgroundColor: status == 'paid'
//                         ? Colors.green
//                         : status == 'overdue'
//                             ? Colors.red
//                             : Colors.orange,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Amount: \$${amount.toStringAsFixed(2)}',
//                 style: Theme.of(context).textTheme.headlineSmall,
//               ),
//               const SizedBox(height: 4),
//               Text('Due: $dueDate'),
//               if (status != 'paid' && onMarkAsPaid != null) ...[
//                 const SizedBox(height: 8),
//                 ElevatedButton(
//                   onPressed: onMarkAsPaid,
//                   child: const Text('Mark as Paid'),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
