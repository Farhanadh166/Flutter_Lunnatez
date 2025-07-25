import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/order_model.dart';
import '../../profile/provider/order_provider.dart';
import '../../complaint/presentation/complaint_list_screen.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order? order;
  bool isLoading = true;
  String? errorMessage;
  bool isConfirming = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      order = await Provider.of<OrderProvider>(context, listen: false)
          .fetchOrderDetail(widget.orderId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _confirmReceived() async {
    setState(() { isConfirming = true; });
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final result = await provider.confirmOrderReceived(widget.orderId);
    setState(() { isConfirming = false; });
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dikonfirmasi diterima')),
      );
      await _fetchDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Gagal konfirmasi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      backgroundColor: Colors.transparent,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : order == null
                  ? const Center(child: Text('Data pesanan tidak ditemukan'))
                  : Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF5F6FA), Color(0xFFE9D8FD)],
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nomor pesanan
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('No. Pesanan: ', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                                    Text(order!.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                                  ],
                                ),
                              ),
                            ),
                            // Ringkasan
                            TweenAnimationBuilder<double>(
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
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                margin: const EdgeInsets.only(bottom: 14),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Total: Rp${order!.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text('Ongkir: Rp${order!.shippingCost}'),
                                          Text('Subtotal: Rp${order!.subtotal}'),
                                          Text('Tanggal: ${order!.createdAt.substring(0, 10)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                        ],
                                      ),
                                      _OrderStatusBadge(status: order!.status),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Produk
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Daftar Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    ...order!.items.map((item) => Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.08),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.network(
                                                    item.gambar,
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(item.nama, style: const TextStyle(fontWeight: FontWeight.w500)),
                                                    Text('Qty: ${item.jumlah}', style: const TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              Text('Rp${item.subtotal}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            // Alamat
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Alamat Pengiriman:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(order!.address.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    Text(order!.address.address),
                                    Text('${order!.address.city}, ${order!.address.province} ${order!.address.postalCode}'),
                                    Text('Telp: ${order!.address.phone}'),
                                  ],
                                ),
                              ),
                            ),
                            // Pembayaran
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Status Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(
                                      order!.payment?.status ?? '-',
                                      style: TextStyle(
                                        color: (order!.payment?.status ?? '').toLowerCase() == 'lunas'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Metode Pembayaran: ${order!.paymentMethod}'),
                                    if (order!.payment?.paymentDate != null)
                                      Text('Tanggal Bayar: ${order!.payment!.paymentDate}'),
                                    if (order!.payment?.proofUrl != null && order!.payment!.proofUrl!.isNotEmpty) ...[
                                      const Divider(height: 24),
                                      const Text('Bukti Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AppBar(
                                                    title: const Text('Bukti Pembayaran'),
                                                    actions: [
                                                      IconButton(
                                                        icon: const Icon(Icons.close),
                                                        onPressed: () => Navigator.pop(context),
                                                      ),
                                                    ],
                                                  ),
                                                  Flexible(
                                                    child: InteractiveViewer(
                                                      child: Image.network(
                                                        order!.payment!.proofUrl!,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              order!.payment!.proofUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                                      SizedBox(height: 8),
                                                      Text('Gagal memuat gambar'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    AppBar(
                                                      title: const Text('Bukti Pembayaran'),
                                                      actions: [
                                                        IconButton(
                                                          icon: const Icon(Icons.close),
                                                          onPressed: () => Navigator.pop(context),
                                                        ),
                                                      ],
                                                    ),
                                                    Flexible(
                                                      child: InteractiveViewer(
                                                        child: Image.network(
                                                          order!.payment!.proofUrl!,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.zoom_in),
                                          label: const Text('Lihat Bukti Pembayaran'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            // Status & aksi
                            if (order!.status == 'shipped')
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    onPressed: isConfirming ? null : _confirmReceived,
                                    child: isConfirming
                                        ? const SizedBox(
                                            width: 18, height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text('Konfirmasi Diterima'),
                                  ),
                                ),
                              ),
                            if (order!.status == 'completed')
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Pesanan sudah diterima. Terima kasih!', style: TextStyle(color: Colors.green)),
                              ),
                            if (order!.status == 'cancelled')
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Pesanan dibatalkan.', style: TextStyle(color: Colors.red)),
                              ),
                            if (order!.status == 'pending')
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Menunggu konfirmasi admin.', style: TextStyle(color: Colors.orange)),
                              ),
                            if (order!.status == 'paid')
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Pembayaran dikonfirmasi, pesanan sedang diproses.', style: TextStyle(color: Colors.blue)),
                              ),
                            if (order!.status == 'shipped')
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Pesanan sedang dikirim.', style: TextStyle(color: Colors.deepPurple)),
                              ),
                            if (order!.payment?.status == 'failed')
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Pembayaran gagal.', style: TextStyle(color: Colors.red)),
                              ),
                            if (order!.payment?.status == 'success')
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Pembayaran sukses.', style: TextStyle(color: Colors.green)),
                              ),
                            // Complaint section - hanya untuk pesanan yang sudah selesai
                            if (order!.status == 'completed') ...[
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.feedback, color: Colors.blue[700]),
                                          const SizedBox(width: 8),
                                          const Text('Komplain', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ComplaintListScreen(
                                                  orderId: int.parse(widget.orderId),
                                                  orderNumber: order!.orderNumber,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.feedback_outlined),
                                          label: const Text('Lihat Komplain'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue[700],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
 