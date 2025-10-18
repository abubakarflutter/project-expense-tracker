import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class BudgetChart extends StatelessWidget {
  final double totalBudget;
  final double totalReceived;
  final double totalRemaining;

  const BudgetChart({
    super.key,
    required this.totalBudget,
    required this.totalReceived,
    required this.totalRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    // Calculate percentages
    final receivedPercentage = totalBudget > 0
        ? (totalReceived / totalBudget) * 100
        : 0.0;
    final remainingPercentage = totalBudget > 0
        ? (totalRemaining / totalBudget) * 100
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Visual bar chart
            if (totalBudget > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      // Received portion
                      if (totalReceived > 0)
                        Expanded(
                          flex: receivedPercentage.toInt(),
                          child: Container(
                            color: AppTheme.successColor,
                            alignment: Alignment.center,
                            child: totalReceived / totalBudget > 0.15
                                ? Text(
                                    '${receivedPercentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      // Remaining portion
                      if (totalRemaining > 0)
                        Expanded(
                          flex: remainingPercentage.toInt(),
                          child: Container(
                            color: AppTheme.warningColor,
                            alignment: Alignment.center,
                            child: totalRemaining / totalBudget > 0.15
                                ? Text(
                                    '${remainingPercentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Legend
            Column(
              children: [
                _buildLegendItem(
                  AppTheme.primaryColor,
                  'Total Budget',
                  currencyFormatter.format(totalBudget),
                  '100%',
                ),
                const SizedBox(height: 12),
                _buildLegendItem(
                  AppTheme.successColor,
                  'Received',
                  currencyFormatter.format(totalReceived),
                  '${receivedPercentage.toStringAsFixed(1)}%',
                ),
                const SizedBox(height: 12),
                _buildLegendItem(
                  AppTheme.warningColor,
                  'Remaining',
                  currencyFormatter.format(totalRemaining),
                  '${remainingPercentage.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    String amount,
    String percentage,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
