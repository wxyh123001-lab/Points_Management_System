import 'package:flutter/material.dart';
import '../models/customer.dart';
import 'milestone_badge.dart';

class CustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;

  const CustomerListTile({super.key, required this.customer, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        customer.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('型号: ${customer.clothingSize}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${customer.points} 分',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 8),
          MilestoneBadge(points: customer.points),
        ],
      ),
    );
  }
}
