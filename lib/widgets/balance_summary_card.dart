import 'package:flutter/material.dart';

class BalanceSummaryCard extends StatelessWidget {
  final String title;
  final double totalBalance;
  final int numberOfOrders;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const BalanceSummaryCard({
    super.key,
    required this.title,
    required this.totalBalance,
    required this.numberOfOrders,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '\$ ${totalBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Basado en $numberOfOrders pedidos completados',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bar_chart),
                label: Text(buttonText),
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
