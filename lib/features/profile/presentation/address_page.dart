import 'package:flutter/material.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alamat Saya')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('+ Tambah Alamat'),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              title: const Text('Jl. Contoh No. 1'),
              subtitle: const Text('Kota, Provinsi, 12345'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {},
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 