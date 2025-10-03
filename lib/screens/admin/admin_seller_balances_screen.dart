import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/providers/order_provider.dart';

class AdminSellerBalancesScreen extends StatelessWidget {
  static const routeName = '/admin-seller-balances';

  const AdminSellerBalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance por Vendedor'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final sellerBalances = orderProvider.sellerBalances;

          if (sellerBalances.isEmpty) {
            return const Center(
              child: Text('No hay datos de ventas para mostrar.'),
            );
          }

          return ListView.builder(
            itemCount: sellerBalances.length,
            itemBuilder: (context, index) {
              final balance = sellerBalances[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  title: Text(
                    balance.storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Text(
                    '\$ ${balance.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
