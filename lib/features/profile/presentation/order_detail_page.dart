import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No. Order: ORD-2025-001', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Status: Dikirim'),
            const SizedBox(height: 8),
            const Text('Produk: Cincin Emas 24K'),
            const SizedBox(height: 8),
            const Text('Alamat: Jl. Contoh No. 1'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Konfirmasi Pesanan Diterima'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 