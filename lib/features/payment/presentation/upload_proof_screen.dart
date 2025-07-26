import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../cart/provider/cart_provider.dart';
import '../../../core/constants.dart';
import '../../order/data/order_service.dart';
import '../../auth/data/auth_service.dart';
import 'package:flutter/services.dart';

final List<Map<String, String>> dummyBankAccounts = [
  {
    'bank': 'BCA',
    'accountNumber': '1234567890',
    'accountName': 'Farhan Adha',
  },
  {
    'bank': 'Mandiri',
    'accountNumber': '9876543210',
    'accountName': 'Farhan Adha',
  },
  {
    'bank': 'BNI',
    'accountNumber': '1122334455',
    'accountName': 'Farhan Adha',
  },
];

String? _statusMessage;

class UploadProofScreen extends StatefulWidget {
  final Map<String, dynamic> checkoutData;

  const UploadProofScreen({
    super.key,
    required this.checkoutData,
  });

  @override
  State<UploadProofScreen> createState() => _UploadProofScreenState();
}

class _UploadProofScreenState extends State<UploadProofScreen> {
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() { _selectedImage = image; });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _submitProof() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih bukti transfer terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() { isLoading = true; _statusMessage = null; });
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');
      final data = widget.checkoutData;
      final response = await OrderService.checkoutWithProof(
        addressId: int.parse(data['address_id'].toString()),
        shippingMethod: data['shipping_method'],
        paymentMethod: data['payment_method'],
        notes: data['notes'],
        items: List<Map<String, dynamic>>.from(data['items']),
        paymentProofPath: _selectedImage!.path,
        paymentNotes: _notesController.text,
        token: token,
      );
      if (response['status'] == true) {
        await Provider.of<CartProvider>(context, listen: false).clearCart();
        setState(() { _statusMessage = response['message'] ?? 'Pesanan berhasil dibuat!'; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_statusMessage!), backgroundColor: AppColors.success),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // Kembali ke keranjang setelah pembayaran berhasil
          Navigator.of(context).pushNamedAndRemoveUntil('/cart', (route) => false);
        }
      } else {
        setState(() { _statusMessage = response['message'] ?? 'Gagal membuat pesanan.'; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_statusMessage!), backgroundColor: AppColors.error),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('UploadProofScreen._submitProof ERROR: ' + e.toString());
      debugPrint('StackTrace: ' + stackTrace.toString());
      setState(() { _statusMessage = e.toString(); });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusMessage!), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nomor rekening disalin!'), backgroundColor: Color(0xFF38BDF8)),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Upload Bukti Transfer',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Rekening Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...dummyBankAccounts.map((bank) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.18)),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.account_balance, color: Color(0xFF38BDF8)),
                        title: Row(
                          children: [
                            Expanded(child: Text('${bank['bank']} - ${bank['accountNumber']}', style: const TextStyle(fontWeight: FontWeight.w600))),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18, color: Color(0xFF38BDF8)),
                              tooltip: 'Copy',
                              onPressed: () => _copyToClipboard(bank['accountNumber']!),
                            ),
                          ],
                        ),
                        subtitle: Text('a.n. ${bank['accountName']}', style: const TextStyle(fontSize: 13)),
                      ),
                    )),
                  ],
                ),
              ),
            ),
                // Instructions Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                         Icon(
                           Icons.info_outline,
                           color: Color(0xFF38BDF8),
                           size: 20,
                         ),
                          const SizedBox(width: 8),
                          Text(
                            'Panduan Upload',
                            style: TextStyle(
                             fontWeight: FontWeight.w600,
                             color: Color(0xFF38BDF8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Format: JPEG, PNG, JPG\n'
                        '• Ukuran maksimal: 2MB\n'
                        '• Pastikan bukti transfer jelas dan lengkap\n'
                        '• Setelah upload, status akan menjadi "Pending"',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Image Upload Section
                Text(
                  'Bukti Transfer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (_selectedImage != null) ...[
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.18)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Ganti Foto'),
                          style: OutlinedButton.styleFrom(foregroundColor: Color(0xFF7C3AED)),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Bukti Transfer'),
                    style: OutlinedButton.styleFrom(foregroundColor: Color(0xFF7C3AED)),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Pembayaran (opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitProof,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Selesaikan Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
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
                ],
              ],
            ),
          ),
    );
  }
} 