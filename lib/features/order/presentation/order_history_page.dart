import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../profile/provider/order_provider.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  static const List<String> tabTitles = [
    'Semua', 'Menunggu Konfirmasi', 'Dibayar', 'Dikirim', 'Selesai', 'Dibatalkan'
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderProvider()..fetchOrderHistoryGrouped(),
      child: const _OrderHistoryBody(),
    );
  }
}

class _OrderHistoryBody extends StatefulWidget {
  const _OrderHistoryBody();

  @override
  State<_OrderHistoryBody> createState() => _OrderHistoryBodyState();
}

class _OrderHistoryBodyState extends State<_OrderHistoryBody> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            // Search bar
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey[600], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: provider.setSearch,
                      decoration: const InputDecoration(
                        hintText: 'Cari pesanan Anda...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        toolbarHeight: 100, // Kurangi tinggi AppBar
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5F6FA), Color(0xFFE9D8FD)],
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(OrderHistoryPage.tabTitles.length, (i) {
                  final selected = provider.tabIndex == i;
                  return GestureDetector(
                    onTap: () => provider.setTab(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected ? Colors.deepPurple[50] : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        OrderHistoryPage.tabTitles[i],
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          color: selected ? Colors.deepPurple : Colors.black54,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          if (provider.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!provider.isLoading && provider.errorMessage != null)
            Expanded(child: Center(child: Text(provider.errorMessage!))),
          if (!provider.isLoading && provider.errorMessage == null)
            Expanded(
              child: provider.filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 80, color: Colors.purple[100]),
                          const SizedBox(height: 16),
                          const Text('Belum ada pesanan', style: TextStyle(fontSize: 20, color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Ayo belanja dan nikmati pengalaman terbaik!', style: TextStyle(fontSize: 14, color: Color(0xFF7C3AED)), textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await provider.fetchOrderHistoryGrouped();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data pesanan diperbarui'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.filteredOrders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final order = provider.filteredOrders[i];
                          final mainItem = order.items.isNotEmpty ? order.items[0] : null;
                          final otherCount = order.items.length > 1 ? order.items.length - 1 : 0;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 400),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 4,
                              shadowColor: Colors.purple.withOpacity(0.08),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChangeNotifierProvider.value(
                                        value: Provider.of<OrderProvider>(context, listen: false),
                                        child: OrderDetailPage(orderId: order.orderId),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Foto produk utama + thumbnail produk lain
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: mainItem != null && mainItem.gambar.isNotEmpty
                                                ? Image.network(
                                                    mainItem.gambar,
                                                    width: 56,
                                                    height: 56,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 56,
                                                    height: 56,
                                                    color: Colors.grey[300],
                                                    child: Icon(Icons.image, color: Colors.grey[500]),
                                                  ),
                                          ),
                                          if (otherCount > 0)
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                width: 22,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(color: Colors.purple, width: 2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '+$otherCount',
                                                    style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),
                                      // Detail pesanan
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Nama produk utama + info produk lain
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    mainItem != null
                                                        ? mainItem.nama + (otherCount > 0 ? ' +$otherCount produk lain' : '')
                                                        : 'Produk tidak ditemukan',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                _OrderStatusBadge(status: order.status),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text('Tanggal: ${order.createdAt.substring(0, 10)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                            Text('Total: Rp${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7C3AED), fontSize: 14)),
                                            Text('Jumlah item: ${order.items.length}', style: const TextStyle(fontSize: 13)),
                                            if (order.paymentMethod.isNotEmpty)
                                              Text('Metode: ${order.paymentMethod}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            // Estimasi pengiriman dihapus karena tidak ada di model
                                            if (order.payment?.status != null && order.payment!.status.isNotEmpty)
                                              Text('Status Bayar: ${order.payment!.status}', style: TextStyle(fontSize: 12, color: order.payment!.status.toLowerCase() == 'lunas' ? Colors.green : Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String status;
  const _OrderStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData? icon;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Menunggu Konfirmasi';
        icon = Icons.hourglass_empty;
        break;
      case 'paid':
        color = Colors.blue;
        text = 'Dibayar';
        icon = Icons.attach_money;
        break;
      case 'shipped':
        color = Colors.deepPurple;
        text = 'Dikirim';
        icon = Icons.local_shipping;
        break;
      case 'completed':
        color = Colors.green;
        text = 'Selesai';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Dibatalkan';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.info_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.18 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
} 