// TODO: Add projects-specific widgets here
// import 'package:flutter/material.dart';

// class ProjectCard extends StatelessWidget {
//   final String name;
//   final String description;
//   final double totalBudget;
//   final double receivedAmount;
//   final String status;
//   final VoidCallback onTap;
//
//   const ProjectCard({
//     Key? key,
//     required this.name,
//     required this.description,
//     required this.totalBudget,
//     required this.receivedAmount,
//     required this.status,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final remaining = totalBudget - receivedAmount;
//     final progress = totalBudget > 0 ? receivedAmount / totalBudget : 0.0;
//
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
//                   Text(name, style: Theme.of(context).textTheme.titleLarge),
//                   Chip(label: Text(status)),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(description),
//               const SizedBox(height: 16),
//               LinearProgressIndicator(value: progress),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Budget: \$${totalBudget.toStringAsFixed(2)}'),
//                   Text('Remaining: \$${remaining.toStringAsFixed(2)}'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
