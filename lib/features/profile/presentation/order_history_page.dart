import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              title: const Text('ORD-2025-001'),
              subtitle: const Text('Status: Selesai'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {}, // Navigasi ke OrderDetailPage
            ),
          ),
        ],
      ),
    );
  }
} 