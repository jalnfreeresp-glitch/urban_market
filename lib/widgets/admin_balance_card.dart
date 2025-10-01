
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/screens/admin/admin_seller_balances_screen.dart';
import 'package:urban_market/widgets/balance_summary_card.dart';

class AdminBalanceCard extends StatelessWidget {
  const AdminBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final totalBalance = orderProvider.platformTotalBalance;
    final numberOfOrders = orderProvider.orders.length;

    return BalanceSummaryCard(
      title: 'Balance Total de la Plataforma',
      totalBalance: totalBalance,
      numberOfOrders: numberOfOrders,
      buttonText: 'Ver Balance por Vendedor',
      onButtonPressed: () {
        Navigator.pushNamed(context, AdminSellerBalancesScreen.routeName);
      },
    );
  }
}
