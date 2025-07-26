import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lunnatezz/features/checkout/data/services/checkout_service.dart';
import 'package:provider/provider.dart';
import '../../cart/provider/cart_provider.dart';

class QrisPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> checkoutData;
  const QrisPaymentScreen({Key? key, required this.checkoutData}) : super(key: key);

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  File? _proofImage;
  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _proofImage = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan upload bukti transfer terlebih dahulu!')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final checkoutService = CheckoutService();
      final response = await checkoutService.checkoutWithProof(
        addressId: int.parse(widget.checkoutData['address_id'].toString()),
        shippingMethod: widget.checkoutData['shipping_method'],
        paymentMethod: 'qris',
        items: widget.checkoutData['items'],
        paymentProof: _proofImage!,
        notes: widget.checkoutData['notes'],
        paymentNotes: 'Transfer via QRIS DANA',
      );
      setState(() {
        _statusMessage = response['message'] ?? 'Pesanan berhasil, menunggu verifikasi admin.';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Provider.of<CartProvider>(context, listen: false).clearCart();
        // Kembali ke keranjang setelah pembayaran berhasil
        Navigator.of(context).pushNamedAndRemoveUntil('/cart', (route) => false);
      }
    } catch (e) {
      setState(() {
        _statusMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran QRIS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Scan QRIS untuk Pembayaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // QR code dengan border & shadow
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFF7C3AED), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7C3AED).withOpacity(0.15),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/qr_dana.jpg',
                  width: 220,
                  height: 220,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Logo e-wallet
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/dana.png', width: 36, height: 36),
                SizedBox(width: 8),
                Image.asset('assets/ovo.jpg', width: 36, height: 36),
                SizedBox(width: 8),
                Image.asset('assets/gopay.png', width: 36, height: 36),
                SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 12),
            // Info QRIS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Color(0xFF7C3AED), size: 18),
                SizedBox(width: 6),
                Text(
                  'QRIS berlaku 1x transaksi',
                  style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Silakan scan QRIS di atas menggunakan aplikasi DANA, OVO, GoPay, ShopeePay, atau e-wallet lain yang mendukung QRIS. Setelah transfer, upload bukti pembayaran di bawah ini.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Preview bukti transfer atau tombol upload
            _proofImage != null
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_proofImage!, width: 180, height: 180, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Ganti Bukti Transfer'),
                        style: OutlinedButton.styleFrom(foregroundColor: Color(0xFF7C3AED)),
                      ),
                    ],
                  )
                : OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Bukti Transfer'),
                    style: OutlinedButton.styleFrom(foregroundColor: Color(0xFF7C3AED)),
                  ),
            const SizedBox(height: 24),
            // Tombol submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Kirim & Selesaikan Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 24),
              Text(
                _statusMessage!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _statusMessage!.toLowerCase().contains('berhasil') ? Color(0xFF22C55E) : Color(0xFFEF4444),
                ),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }
} 