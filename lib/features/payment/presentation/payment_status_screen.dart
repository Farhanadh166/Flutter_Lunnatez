import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/payment_provider.dart';
import '../../../core/constants.dart';

class PaymentStatusScreen extends StatefulWidget {
  final String orderId;

  const PaymentStatusScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchPaymentStatus(widget.orderId);
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'paid':
        return AppColors.primaryBlue;
      case 'verified':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'paid':
        return Icons.payment;
      case 'verified':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'paid':
        return 'Sudah Dibayar';
      case 'verified':
        return 'Terverifikasi';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Status Pembayaran',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.read<PaymentProvider>().fetchPaymentStatus(widget.orderId);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          if (paymentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paymentProvider.error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      paymentProvider.fetchPaymentStatus(widget.orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final paymentStatus = paymentProvider.paymentStatus;
          if (paymentStatus == null) {
            return const Center(
              child: Text(
                'Data status pembayaran tidak ditemukan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _getStatusColor(paymentStatus.status).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(paymentStatus.status),
                          size: 40,
                          color: _getStatusColor(paymentStatus.status),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getStatusText(paymentStatus.status),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Roboto',
                          color: _getStatusColor(paymentStatus.status),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order ID: ${paymentStatus.orderId}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto',
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (paymentStatus.paymentMethod != null) ...[
                        _buildDetailRow('Metode Pembayaran', paymentStatus.paymentMethod!),
                        const SizedBox(height: 12),
                      ],
                      if (paymentStatus.totalAmount != null) ...[
                        _buildDetailRow('Total Pembayaran', 'Rp${paymentStatus.totalAmount}'),
                        const SizedBox(height: 12),
                      ],
                      if (paymentStatus.shippingCost != null) ...[
                        _buildDetailRow('Biaya Kirim', 'Rp${paymentStatus.shippingCost}'),
                        const SizedBox(height: 12),
                      ],
                      if (paymentStatus.subtotal != null) ...[
                        _buildDetailRow('Subtotal', 'Rp${paymentStatus.subtotal}'),
                        const SizedBox(height: 12),
                      ],
                      if (paymentStatus.address != null) ...[
                        _buildDetailRow('Alamat', '${paymentStatus.address!.address}, ${paymentStatus.address!.city}'),
                        const SizedBox(height: 12),
                      ],
                      if (paymentStatus.items != null && paymentStatus.items!.isNotEmpty) ...[
                        Text(
                          'Produk:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                            color: AppColors.grey,
                          ),
                        ),
                        ...paymentStatus.items!.map((item) => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: Text('- ${item.nama} (Qty: ${item.jumlah})'),
                        )),
                        const SizedBox(height: 12),
                      ],
                      if (paymentStatus.payment != null && paymentStatus.payment!.proofUrl != null && paymentStatus.payment!.proofUrl!.isNotEmpty) ...[
                        _buildDetailRow('Bukti Pembayaran', ''),
                        const SizedBox(height: 8),
                        Image.network(paymentStatus.payment!.proofUrl!, height: 120),
                        const SizedBox(height: 12),
                      ],
                      if (paymentStatus.paidAt != null) ...[
                        _buildDetailRow('Tanggal Pembayaran', _formatDate(paymentStatus.paidAt!)),
                        const SizedBox(height: 12),
                      ],
                      if (paymentStatus.verifiedAt != null) ...[
                        _buildDetailRow('Tanggal Verifikasi', _formatDate(paymentStatus.verifiedAt!)),
                        const SizedBox(height: 12),
                      ],
                      if (paymentStatus.notes != null && paymentStatus.notes!.isNotEmpty) ...[
                        _buildDetailRow('Catatan', paymentStatus.notes!),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Proof Image

                // Action Buttons
                if (paymentStatus.isRejected) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to upload proof screen
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upload Ulang Bukti',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
              color: AppColors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 