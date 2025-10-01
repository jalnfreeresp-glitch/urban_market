import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/providers/order_provider.dart';

enum BalancePeriod { day, week, month, total }

class SellerBalanceCard extends StatefulWidget {
  const SellerBalanceCard({super.key});

  @override
  State<SellerBalanceCard> createState() => _SellerBalanceCardState();
}

class _SellerBalanceCardState extends State<SellerBalanceCard> {
  BalancePeriod _selectedPeriod = BalancePeriod.day;

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    double balance = 0;
    switch (_selectedPeriod) {
      case BalancePeriod.day:
        balance = orderProvider.dailyBalance;
        break;
      case BalancePeriod.week:
        balance = orderProvider.weeklyBalance;
        break;
      case BalancePeriod.month:
        balance = orderProvider.monthlyBalance;
        break;
      case BalancePeriod.total:
        balance = orderProvider.totalBalance;
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance de Ventas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'S/. ${balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ToggleButtons(
                isSelected: [
                  _selectedPeriod == BalancePeriod.day,
                  _selectedPeriod == BalancePeriod.week,
                  _selectedPeriod == BalancePeriod.month,
                  _selectedPeriod == BalancePeriod.total,
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedPeriod = BalancePeriod.values[index];
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.deepPurple,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Día'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Semana'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Mes'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Total'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
