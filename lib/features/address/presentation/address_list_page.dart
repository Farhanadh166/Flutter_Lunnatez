import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/address_provider.dart';

class AddressListPage extends StatelessWidget {
  final String token;
  const AddressListPage({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddressProvider()..fetchAddresses(token),
      child: Consumer<AddressProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Alamat'),
              backgroundColor: Colors.purple,
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/address/add', arguments: token);
                if (result == true) provider.fetchAddresses(token);
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Alamat'),
            ),
            body: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF5F6FA), Color(0xFFE9D8FD)],
                ),
              ),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.addresses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_off, size: 80, color: Colors.purple[100]),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada alamat',
                                style: TextStyle(fontSize: 20, color: Color(0xFF7C3AED), fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tambahkan alamat untuk memudahkan pengiriman',
                                style: TextStyle(fontSize: 14, color: Color(0xFF7C3AED)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(context, '/address/add', arguments: token);
                                  if (result == true) provider.fetchAddresses(token);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Alamat Pertama'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: provider.addresses.length,
                          itemBuilder: (context, i) {
                            final a = provider.addresses[i];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    final result = await Navigator.pushNamed(context, '/address/edit', arguments: {'token': token, 'address': a});
                                    if (result == true) provider.fetchAddresses(token);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      leading: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6, right: 6), // Tambah padding agar badge tidak terpotong
                                            child: Icon(
                                              Icons.location_on,
                                              color: a['is_primary'] == true ? Colors.purple : Colors.grey,
                                              size: 32,
                                            ),
                                          ),
                                          if (a['is_primary'] == true)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.purple,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text('Utama', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                        ],
                                      ),
                                      title: Text(
                                        a['address'] ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${a['name']} | ${a['phone']}',
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF7C3AED)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${a['city']}, ${a['province']} ${a['postal_code']}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      isThreeLine: true,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                            tooltip: 'Edit Alamat',
                                            onPressed: () async {
                                              final result = await Navigator.pushNamed(context, '/address/edit', arguments: {'token': token, 'address': a});
                                              if (result == true) provider.fetchAddresses(token);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                            tooltip: 'Hapus Alamat',
                                            onPressed: () async {
                                              final confirm = await showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text('Hapus Alamat'),
                                                  content: const Text('Yakin ingin menghapus alamat ini?'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                await provider.deleteAddress(token, a['id']);
                                                if (provider.error == null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat dihapus')));
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!)));
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          );
        },
      ),
    );
  }
} 