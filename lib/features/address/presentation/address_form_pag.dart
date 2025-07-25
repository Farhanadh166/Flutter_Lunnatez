import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/address_provider.dart';

class AddressFormPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? address; // null = tambah, ada = edit
  const AddressFormPage({Key? key, required this.token, this.address}) : super(key: key);

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameC, phoneC, addressC, cityC, provinceC, postalC;
  bool isPrimary = false;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.address?['name'] ?? '');
    phoneC = TextEditingController(text: widget.address?['phone'] ?? '');
    addressC = TextEditingController(text: widget.address?['address'] ?? '');
    cityC = TextEditingController(text: widget.address?['city'] ?? '');
    provinceC = TextEditingController(text: widget.address?['province'] ?? '');
    postalC = TextEditingController(text: widget.address?['postal_code'] ?? '');
    isPrimary = widget.address?['is_primary'] == true;
  }

  @override
  void dispose() {
    nameC.dispose(); phoneC.dispose(); addressC.dispose(); cityC.dispose(); provinceC.dispose(); postalC.dispose();
    super.dispose();
  }

  String? _validateNotEmpty(String? v) => (v == null || v.trim().isEmpty) ? 'Tidak boleh kosong' : null;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddressProvider>(context);
    final isEdit = widget.address != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Alamat' : 'Tambah Alamat'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFF5F6FA),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEdit ? 'Edit data alamat Anda di bawah ini.' : 'Isi data alamat pengiriman dengan benar.',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF7C3AED)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: nameC,
                        decoration: const InputDecoration(labelText: 'Nama'),
                        validator: _validateNotEmpty,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneC,
                        decoration: const InputDecoration(labelText: 'Nomor HP'),
                        keyboardType: TextInputType.phone,
                        validator: _validateNotEmpty,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressC,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                        validator: _validateNotEmpty,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cityC,
                        decoration: const InputDecoration(labelText: 'Kota'),
                        validator: _validateNotEmpty,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: provinceC,
                        decoration: const InputDecoration(labelText: 'Provinsi'),
                        validator: _validateNotEmpty,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: postalC,
                        decoration: const InputDecoration(labelText: 'Kode Pos'),
                        keyboardType: TextInputType.number,
                        validator: _validateNotEmpty,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Text('Jadikan alamat utama', style: TextStyle(fontSize: 15, color: Colors.grey[800]))),
                          Switch(
                            value: isPrimary,
                            onChanged: (v) => setState(() => isPrimary = v),
                            activeColor: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final data = {
                                      'name': nameC.text.trim(),
                                      'phone': phoneC.text.trim(),
                                      'address': addressC.text.trim(),
                                      'city': cityC.text.trim(),
                                      'province': provinceC.text.trim(),
                                      'postal_code': postalC.text.trim(),
                                      'is_primary': isPrimary,
                                    };
                                    bool result;
                                    if (isEdit) {
                                      result = await provider.editAddress(widget.token, widget.address!['id'], data);
                                    } else {
                                      result = await provider.addAddress(widget.token, data);
                                    }
                                    if (result) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Alamat berhasil diedit' : 'Alamat berhasil ditambah')));
                                      Navigator.pop(context, true);
                                    } else if (provider.error != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!)));
                                    }
                                  }
                                },
                                child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Alamat'),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 