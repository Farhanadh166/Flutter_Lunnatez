import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/payment_provider.dart';
import '../data/payment_method.dart';
import '../../../core/constants.dart';
import 'upload_proof_screen.dart';
import 'package:lunnatezz/features/checkout/data/services/checkout_service.dart';
import 'qris_payment_screen.dart';
import '../../cart/provider/cart_provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Map<String, dynamic> checkoutData;

  const PaymentMethodScreen({
    super.key,
    required this.checkoutData,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  // Tambahkan state untuk menyimpan metode terakhir & favorit
  String? _lastSelectedMethodId;
  String? _recommendedMethodId = 'transfer_bank'; // Contoh, bisa diambil dari provider/user data

  @override
  void initState() {
    super.initState();
    debugPrint('PaymentMethodScreen.initState - Starting...');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('PaymentMethodScreen.initState - Fetching payment methods...');
      context.read<PaymentProvider>().fetchPaymentMethods();
      // Ambil metode terakhir dari local storage/user data jika ada
      // setState(() { _lastSelectedMethodId = ... })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          debugPrint('PaymentMethodScreen.build - Building with ${paymentProvider.paymentMethods.length} methods');
          
          if (paymentProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          if (paymentProvider.error != null) {
            debugPrint('PaymentMethodScreen.build - Error: ${paymentProvider.error}');
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paymentProvider.error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('PaymentMethodScreen.build - Retry button pressed');
                      paymentProvider.fetchPaymentMethods();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                  if (paymentProvider.error!.contains('login ulang'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () {
                          debugPrint('PaymentMethodScreen.build - Login button pressed');
                          // Navigate back to login screen
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Kembali ke Login'),
                      ),
                    ),
                ],
              ),
            );
          }

          if (paymentProvider.paymentMethods.isEmpty) {
            debugPrint('PaymentMethodScreen.build - No payment methods available');
            return const Center(
              child: Text(
                'Tidak ada metode pembayaran tersedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return Column(
            children: [
              // Payment Methods List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: paymentProvider.paymentMethods.length,
                  itemBuilder: (context, index) {
                    try {
                      final method = paymentProvider.paymentMethods[index];
                      debugPrint('PaymentMethodScreen.build - Building method at index $index: ${method.name} (ID: ${method.id})');
                      return _buildPaymentMethodCard(method);
                    } catch (e, stackTrace) {
                      debugPrint('PaymentMethodScreen.build - Error building payment method at index $index: $e');
                      debugPrint('PaymentMethodScreen.build - Stack trace: $stackTrace');
                      return Container(); // Return empty container on error
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _lastSelectedMethodId == method.id;
    Color cardColor;
    Color borderColor;
    switch (method.id) {
      case 'transfer_bank':
        cardColor = const Color(0xFFEFF6FF); // biru muda
        borderColor = const Color(0xFF38BDF8); // biru
        break;
      case 'cod':
        cardColor = const Color(0xFFF0FDF4); // hijau muda
        borderColor = const Color(0xFF22C55E); // hijau
        break;
      case 'qris':
        cardColor = const Color(0xFFF3F0FF); // ungu muda
        borderColor = const Color(0xFF7C3AED); // ungu
        break;
      default:
        cardColor = AppColors.white;
        borderColor = AppColors.primaryBlue;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(isSelected ? 20 : 12),
        border: Border.all(
          color: isSelected ? borderColor : Colors.transparent,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(isSelected ? 0.25 : 0.10),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isSelected ? 20 : 12),
          onTap: () async {
            setState(() {
              _lastSelectedMethodId = method.id;
            });
            // Simpan ke local storage jika perlu
            debugPrint('PaymentMethodScreen._buildPaymentMethodCard - Method tapped: ${method.name} (ID: ${method.id}, Code: ${method.code})');
            final updatedCheckoutData = Map<String, dynamic>.from(widget.checkoutData);
            updatedCheckoutData['payment_method'] = method.id;

            if (method.id == 'cod') {
              // Proses checkout COD langsung
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              try {
                final checkoutService = CheckoutService();
                final result = await checkoutService.checkout(
                  addressId: int.parse(updatedCheckoutData['address_id'].toString()),
                  shippingMethod: updatedCheckoutData['shipping_method'],
                  paymentMethod: 'cod',
                  notes: updatedCheckoutData['notes'],
                );
                Navigator.of(context).pop(); // Tutup loading
                // Tampilkan detail pesanan/konfirmasi sukses
                Provider.of<CartProvider>(context, listen: false).clearCart();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pesanan COD Berhasil'),
                    content: Text(result['message'] ?? 'Pesanan COD berhasil dibuat!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Kembali ke keranjang setelah pembayaran berhasil
                          Navigator.of(context).pushNamedAndRemoveUntil('/cart', (route) => false);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop(); // Tutup loading
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Gagal'),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              }
            } else if (method.id == 'qris') {
              // Navigasi ke halaman pembayaran QRIS
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrisPaymentScreen(
                    checkoutData: updatedCheckoutData,
                  ),
                ),
              );
            } else {
              // Metode lain (misal transfer bank), lanjut ke upload bukti
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadProofScreen(
                    checkoutData: updatedCheckoutData,
                  ),
                ),
              );
            }
          },
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: method.icon != null && method.icon!.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        method.icon!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('PaymentMethodScreen._buildPaymentMethodCard - Error loading icon: $error');
                          return _buildIconFallback(method.icon);
                        },
                      ),
                    )
                  : _buildIconFallback(method.icon),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? borderColor : AppColors.darkGrey,
                    ),
                  ),
                ),
                if (_recommendedMethodId == method.id)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rekomendasi',
                      style: TextStyle(
                        color: borderColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              method.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: isSelected ? borderColor : AppColors.grey,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconFallback(String? icon) {
    if (icon == null || icon.isEmpty) {
      return const Icon(
        Icons.payment,
        color: AppColors.primaryBlue,
      );
    }

    // Check if icon is an emoji (bank emoji)
    if (icon.contains('🏦') || icon.contains('bank')) {
      return const Icon(
        Icons.account_balance,
        color: AppColors.primaryBlue,
      );
    }

    // Check if icon is an emoji (credit card emoji)
    if (icon.contains('💳') || icon.contains('card')) {
      return const Icon(
        Icons.credit_card,
        color: AppColors.primaryBlue,
      );
    }

    // Check if icon is an emoji (money emoji)
    if (icon.contains('💰') || icon.contains('money')) {
      return const Icon(
        Icons.attach_money,
        color: AppColors.primaryBlue,
      );
    }

    // Default payment icon
    return const Icon(
      Icons.payment,
      color: AppColors.primaryBlue,
    );
  }
} 