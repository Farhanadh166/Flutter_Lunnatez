import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/payment/provider/payment_provider.dart';
import '../../features/payment/data/payment_method.dart';
import '../../core/constants.dart';

class PaymentMethodSelector extends StatefulWidget {
  final Function(PaymentMethod) onMethodSelected;
  final PaymentMethod? selectedMethod;

  const PaymentMethodSelector({
    super.key,
    required this.onMethodSelected,
    this.selectedMethod,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        if (paymentProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            ),
          );
        }

        if (paymentProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat metode pembayaran',
                  style: TextStyle(fontSize: 12, color: AppColors.error, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    paymentProvider.fetchPaymentMethods();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (paymentProvider.paymentMethods.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tidak ada metode pembayaran tersedia',
              style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Poppins'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            ...paymentProvider.paymentMethods.cast<PaymentMethod>().map((method) {
              final isSelected = (widget.selectedMethod?.id ?? '') == method.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : AppColors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: RadioListTile<PaymentMethod>(
                  value: method,
                  groupValue: widget.selectedMethod,
                  onChanged: (PaymentMethod? value) {
                    if (value != null) {
                      widget.onMethodSelected(value);
                    }
                  },
                  title: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: method.icon != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  method.icon!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.payment,
                                      color: AppColors.primaryBlue,
                                      size: 20,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.payment,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkGrey, fontFamily: 'Poppins'),
                            ),
                            Text(
                              method.description,
                              style: TextStyle(fontSize: 14, color: AppColors.darkGrey, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  activeColor: AppColors.primaryBlue,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
} 