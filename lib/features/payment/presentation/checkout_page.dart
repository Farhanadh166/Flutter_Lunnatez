import 'package:flutter/material.dart';
import 'package:lunnatezz/features/checkout/data/services/checkout_service.dart';
import 'package:provider/provider.dart';
import '../../order/data/order_service.dart';
import '../../order/data/order_model.dart' as order;
import '../../cart/provider/cart_provider.dart';
import 'payment_method_screen.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedAddressId;
  String? selectedShippingId;
  String? notes;

  bool isLoading = false;
  String? errorMessage;

  List<order.Address> addresses = [];
  List<order.ShippingMethod> shippingMethods = [];
  bool showAddAddressForm = false;
  final _formKey = GlobalKey<FormState>();
  String? newName, newPhone, newAddress, newCity, newProvince, newPostalCode;
  bool newIsPrimary = false;

  @override
  void initState() {
    super.initState();
    debugPrint('CheckoutPage.initState - Starting...');
    // Refresh cart data terlebih dahulu
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cart = Provider.of<CartProvider>(context, listen: false);
      await cart.forceRefresh();
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    debugPrint('CheckoutPage._fetchData - Starting...');
    setState(() { isLoading = true; errorMessage = null; });
    try {
      debugPrint('CheckoutPage._fetchData - Fetching addresses...');
      final addr = await OrderService.getAddresses();
      debugPrint('CheckoutPage._fetchData - Addresses count: ${addr.length}');
      
      debugPrint('CheckoutPage._fetchData - Fetching shipping methods...');
      final ship = await OrderService.getShippingMethods();
      debugPrint('CheckoutPage._fetchData - Shipping methods count: ${ship.length}');
      
      setState(() {
        addresses = addr;
        shippingMethods = ship;
        if (addresses.isNotEmpty) {
          selectedAddressId = addresses.first.id;
          debugPrint('CheckoutPage._fetchData - Selected address ID: $selectedAddressId');
        }
        if (shippingMethods.isNotEmpty) {
          selectedShippingId = shippingMethods.first.id;
          debugPrint('CheckoutPage._fetchData - Selected shipping ID: $selectedShippingId');
        }
      });
    } catch (e, stackTrace) {
      debugPrint('CheckoutPage._fetchData - Error: $e');
      debugPrint('CheckoutPage._fetchData - Stack trace: $stackTrace');
      setState(() { errorMessage = e.toString(); });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _goToPayment() async {
    debugPrint('CheckoutPage._goToPayment - Starting...');
    debugPrint('CheckoutPage._goToPayment - selectedAddressId: $selectedAddressId');
    debugPrint('CheckoutPage._goToPayment - selectedShippingId: $selectedShippingId');
    debugPrint('CheckoutPage._goToPayment - notes: $notes');

    if (selectedAddressId == null || selectedShippingId == null) {
      debugPrint('CheckoutPage._goToPayment - Missing required selections');
      setState(() { errorMessage = 'Pilih alamat dan pengiriman.'; });
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);
    final selectedAddress = addresses.firstWhere((a) => a.id == selectedAddressId, orElse: () => addresses.first);
    final selectedShipping = shippingMethods.firstWhere((s) => s.id == selectedShippingId, orElse: () => shippingMethods.first);
    int subtotal = cart.items.fold(0, (sum, item) => sum + item.totalHarga);
    int shippingCost = selectedShipping.cost;
    int total = subtotal + shippingCost;

    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Konfirmasi Pesanan', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(item.produk.gambar, width: 36, height: 36, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.produk.nama, style: const TextStyle(fontWeight: FontWeight.w500))),
                      Text('x${item.quantity}', style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
                const SizedBox(height: 10),
                Text('Alamat: ${selectedAddress.name} - ${selectedAddress.address}, ${selectedAddress.city}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                Text('Ekspedisi: ${selectedShipping.name} (Rp${selectedShipping.cost})', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                if (notes != null && notes!.isNotEmpty)
                  Text('Catatan: $notes', style: const TextStyle(fontSize: 13)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED), fontSize: 16)),
                    Text('Rp$total', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED), fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pesanan akan diproses setelah pembayaran diterima',
                  style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Konfirmasi & Lanjut'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    setState(() { isLoading = true; errorMessage = null; });
    try {
      final checkoutData = {
        'address_id': selectedAddressId!,
        'shipping_method': selectedShippingId!,
        'notes': notes,
        'items': cart.items.map((item) => {
          'product_id': item.produk.id,
          'qty': item.quantity,
        }).toList(),
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentMethodScreen(checkoutData: checkoutData),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('CheckoutPage._goToPayment - Error: $e');
      debugPrint('CheckoutPage._goToPayment - Stack trace: $stackTrace');
      setState(() { errorMessage = e.toString(); });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: const Text('Checkout')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : showAddAddressForm
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            const Text('Tambah Alamat Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Nama Penerima'),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                              onSaved: (v) => newName = v,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Nomor HP'),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                              onSaved: (v) => newPhone = v,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Alamat Lengkap'),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                              onSaved: (v) => newAddress = v,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Kota'),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                              onSaved: (v) => newCity = v,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Provinsi'),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                              onSaved: (v) => newProvince = v,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Kode Pos'),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                              onSaved: (v) => newPostalCode = v,
                            ),
                            SizedBox(height: 12),
                            CheckboxListTile(
                              value: newIsPrimary,
                              onChanged: (v) => setState(() => newIsPrimary = v ?? false),
                              title: const Text('Set sebagai alamat utama'),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      debugPrint('CheckoutPage.build - Add address button pressed');
                                      if (_formKey.currentState?.validate() ?? false) {
                                        _formKey.currentState?.save();
                                        debugPrint('CheckoutPage.build - Form validated, saving address...');
                                        debugPrint('CheckoutPage.build - New address data: name=$newName, city=$newCity, province=$newProvince');
                                        
                                        setState(() { isLoading = true; errorMessage = null; });
                                        try {
                                          final addr = await OrderService.addAddress(
                                            name: newName!,
                                            phone: newPhone!,
                                            address: newAddress!,
                                            city: newCity!,
                                            province: newProvince!,
                                            postalCode: newPostalCode!,
                                            isPrimary: newIsPrimary,
                                          );
                                          debugPrint('CheckoutPage.build - Address added successfully, ID: ${addr.id}');
                                          
                                          setState(() {
                                            addresses.add(addr);
                                            selectedAddressId = addr.id;
                                            showAddAddressForm = false;
                                          });
                                          
                                          // Setelah alamat berhasil, fetch shipping/payment
                                          debugPrint('CheckoutPage.build - Refreshing shipping and payment methods...');
                                          setState(() { isLoading = true; });
                                          try {
                                            final ship = await OrderService.getShippingMethods();
                                            final pay = await CheckoutService().getPaymentMethods();
                                            debugPrint('CheckoutPage.build - Refreshed shipping methods: ${ship.length}, payment methods: ${pay.length}');
                                            setState(() {
                                              shippingMethods = ship;
                                            });
                                          } catch (e, stackTrace) {
                                            debugPrint('CheckoutPage.build - Error refreshing shipping/payment: $e');
                                            debugPrint('CheckoutPage.build - Stack trace: $stackTrace');
                                          }
                                          setState(() { isLoading = false; });
                                        } catch (e, stackTrace) {
                                          debugPrint('CheckoutPage.build - Error adding address: $e');
                                          debugPrint('CheckoutPage.build - Stack trace: $stackTrace');
                                          setState(() { errorMessage = e.toString(); });
                                        } finally {
                                          setState(() { isLoading = false; });
                                        }
                                      }
                                    },
                                    child: const Text('Simpan & Pilih'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () => setState(() => showAddAddressForm = false),
                                  child: const Text('Batal'),
                                ),
                              ],
                            ),
                            if (errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                    )
                  : addresses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_off, size: 80, color: Color(0xFFBDBDBD)),
                              const SizedBox(height: 18),
                              const Text(
                                'Belum ada alamat pengiriman',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tambahkan alamat untuk melanjutkan checkout',
                                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => setState(() => showAddAddressForm = true),
                                icon: const Icon(Icons.add_location_alt_rounded),
                                label: const Text('Tambah Alamat Baru'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C3AED),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                  elevation: 2,
                                ),
                              ),
                            ],
                          ),
                        )
                      : (shippingMethods.isEmpty)
                          ? const Center(child: Text('Data pengiriman belum tersedia.'))
                          : SafeArea(
                              child: Stack(
                                children: [
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Ringkasan Keranjang
                                        Card(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                          elevation: 2,
                                          margin: const EdgeInsets.only(bottom: 20),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Ringkasan Keranjang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF7C3AED))),
                                                const SizedBox(height: 12),
                                                ...cart.items.map((item) => Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Image.network(
                                                        item.produk.gambar,
                                                        width: 60,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(item.produk.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                          const SizedBox(height: 2),
                                                          Text('Rp${item.totalHarga}', style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 15)),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF7C3AED).withOpacity(0.08),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text('x${item.quantity}', style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
                                                    ),
                                                  ],
                                                )),
                                                const SizedBox(height: 14),
                                                Builder(
                                                  builder: (context) {
                                                    int shippingCost = 0;
                                                    if (selectedShippingId != null) {
                                                      try {
                                                        final selectedShip = shippingMethods.firstWhere(
                                                          (s) => s.id == selectedShippingId,
                                                          orElse: () => order.ShippingMethod(id: '', name: '', cost: 0),
                                                        );
                                                        shippingCost = selectedShip.cost;
                                                      } catch (_) {
                                                        shippingCost = 0;
                                                      }
                                                    }
                                                    int subtotal = cart.items.fold(0, (sum, item) => sum + item.totalHarga);
                                                    int total = subtotal + shippingCost;
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Text('Ongkir', style: TextStyle(color: Colors.grey)),
                                                            Text('Rp$shippingCost', style: const TextStyle(color: Colors.grey)),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED), fontSize: 16)),
                                                            Text('Rp$total', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED), fontSize: 16)),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Alamat Pengiriman
                                        Card(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                          elevation: 2,
                                          margin: const EdgeInsets.only(bottom: 20),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      child: Text(
                                                        'Alamat Pengiriman',
                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF7C3AED)),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    TextButton.icon(
                                                      onPressed: () => setState(() => showAddAddressForm = true),
                                                      icon: const Icon(Icons.add, size: 18, color: Color(0xFF7C3AED)),
                                                      label: const Text('Alamat Baru', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                        minimumSize: Size(0, 36),
                                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ...addresses.map((addr) => RadioListTile<String>(
                                                  value: addr.id,
                                                  groupValue: selectedAddressId,
                                                  onChanged: (val) {
                                                    setState(() => selectedAddressId = val);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: const Text('Alamat pengiriman dipilih!', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w600)),
                                                        backgroundColor: const Color(0xFFEFFCF6),
                                                        behavior: SnackBarBehavior.floating,
                                                        duration: Duration(milliseconds: 1200),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      ),
                                                    );
                                                  },
                                                  title: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text('${addr.name} - ${addr.address}, ${addr.city}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                                            Text(addr.phone, style: const TextStyle(fontSize: 13)),
                                                          ],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, size: 20, color: Color(0xFFEF4444)),
                                                        tooltip: 'Hapus',
                                                        onPressed: () async {
                                                          final confirm = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                              title: const Text('Hapus Alamat?', style: TextStyle(fontWeight: FontWeight.bold)),
                                                              content: const Text('Yakin ingin menghapus alamat ini?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.of(context).pop(false),
                                                                  child: const Text('Batal'),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed: () => Navigator.of(context).pop(true),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: Color(0xFFEF4444),
                                                                    foregroundColor: Colors.white,
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                  ),
                                                                  child: const Text('Hapus'),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                          if (confirm == true) {
                                                            setState(() {
                                                              addresses.removeWhere((a) => a.id == addr.id);
                                                              if (selectedAddressId == addr.id && addresses.isNotEmpty) {
                                                                selectedAddressId = addresses.first.id;
                                                              } else if (addresses.isEmpty) {
                                                                selectedAddressId = null;
                                                              }
                                                            });
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: const Text('Alamat dihapus', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w600)),
                                                                backgroundColor: const Color(0xFFEFFCF6),
                                                                behavior: SnackBarBehavior.floating,
                                                                duration: Duration(milliseconds: 1200),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  activeColor: const Color(0xFF7C3AED),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Metode Pengiriman
                                        Card(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                          elevation: 2,
                                          margin: const EdgeInsets.only(bottom: 20),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Metode Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF7C3AED))),
                                                ...shippingMethods.map((ship) => RadioListTile<String>(
                                                  value: ship.id,
                                                  groupValue: selectedShippingId,
                                                  onChanged: (val) {
                                                    setState(() => selectedShippingId = val);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: const Text('Metode pengiriman dipilih!', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w600)),
                                                        backgroundColor: const Color(0xFFEFFCF6),
                                                        behavior: SnackBarBehavior.floating,
                                                        duration: Duration(milliseconds: 1200),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      ),
                                                    );
                                                  },
                                                  title: Text('${ship.name} (Rp${ship.cost})', style: const TextStyle(fontWeight: FontWeight.w500)),
                                                  subtitle: ship.estimation != null ? Text('Estimasi: ${ship.estimation}', style: const TextStyle(color: Colors.grey, fontSize: 13)) : null,
                                                  activeColor: const Color(0xFF7C3AED),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Catatan
                                        Card(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                          elevation: 2,
                                          margin: const EdgeInsets.only(bottom: 20),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Catatan (opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C3AED))),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  onChanged: (val) => notes = val,
                                                  decoration: const InputDecoration(hintText: 'Catatan untuk penjual'),
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Setelah section Catatan
                                        Card(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                          elevation: 2,
                                          margin: const EdgeInsets.only(bottom: 20),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Voucher/Promo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C3AED))),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        decoration: const InputDecoration(
                                                          hintText: 'Masukkan kode voucher',
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                                        ),
                                                        onChanged: (val) {},
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: const Text('Fitur voucher belum tersedia', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                                                            backgroundColor: const Color(0xFFFFF1F2),
                                                            behavior: SnackBarBehavior.floating,
                                                            duration: Duration(milliseconds: 1400),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                          ),
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color(0xFF7C3AED),
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                        elevation: 1,
                                                      ),
                                                      child: const Text('Terapkan'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 80),
                                      ],
                                    ),
                                  ),
                                  // Sticky Checkout Button
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : _goToPayment,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF7C3AED),
                                            foregroundColor: Colors.white,
                                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            elevation: 2,
                                          ),
                                          child: const Text('Lanjut ke Pembayaran'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
    );
  }
} 