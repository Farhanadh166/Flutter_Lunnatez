import 'package:flutter/material.dart';
import '../data/product_model.dart';
import '../data/product_service.dart';
import 'package:provider/provider.dart';
import '../../cart/provider/cart_provider.dart';
import '../../../shared/widgets/product_card.dart';
import 'package:flutter/widgets.dart';

class _ProductWithDummy extends Product {
  final String? badge;
  final double rating;
  final int jumlahUlasan;
  _ProductWithDummy(Product p, {this.badge, this.rating = 4.5, this.jumlahUlasan = 12})
      : super(
          id: p.id,
          nama: p.nama,
          harga: p.harga,
          deskripsi: p.deskripsi,
          gambar: p.gambar,
          kategoriId: p.kategoriId,
          kategori: p.kategori,
          stok: p.stok,
        );
}

class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Product> _futureProduct;
  List<Product> _relatedProducts = [];
  bool _isLoadingRelated = false;
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _futureProduct = ProductService.getProductDetail(widget.productId);
  }

  Future<void> _fetchRelatedProducts(int kategoriId, int currentProductId) async {
    setState(() { _isLoadingRelated = true; });
    try {
      final products = await ProductService.getProductsByCategory(kategoriId);
      setState(() {
        _relatedProducts = products.where((p) => p.id != currentProductId).toList();
        debugPrint('Related products fetched: ${_relatedProducts.length}');
      });
    } catch (_) {
      setState(() { _relatedProducts = []; });
    } finally {
      setState(() { _isLoadingRelated = false; });
    }
  }

  Future<_ProductWithDummy> get _futureProductWithDummyFields async {
    final product = await _futureProduct;
    return _ProductWithDummy(
      product,
      badge: product.id % 3 == 0 ? 'Baru' : (product.id % 3 == 1 ? 'Diskon' : null),
      rating: 4.5,
      jumlahUlasan: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 4,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          title: const Text(
            'Detail Produk',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: FutureBuilder<_ProductWithDummy>(
        future: _futureProductWithDummyFields,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat detail produk: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Produk tidak ditemukan'));
          }
          final product = snapshot.data!;
          // Fetch related products jika belum
          if (_relatedProducts.isEmpty && !_isLoadingRelated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchRelatedProducts(product.kategoriId, product.id);
            });
          }
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 90, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Stack(
              children: [
                Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    product.imageUrl,
                                    width: 240,
                                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
                              ),
                              // Badge
                              if (product.badge != null)
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: product.badge == 'Diskon' ? Colors.amber : Color(0xFF7C3AED),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      product.badge!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              // Wishlist button
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: Implementasi wishlist
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Wishlist coming soon!'),
                                        backgroundColor: Color(0xFFE9D8FD),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.favorite_border, color: Color(0xFF7C3AED)),
                                  ),
                                ),
                              ),
                              // Share button
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: Implementasi share produk
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Fitur share coming soon!'),
                                        backgroundColor: Color(0xFFE9D8FD),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.share, color: Color(0xFF7C3AED)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.nama,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF22223B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          product.formattedPrice,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7C3AED),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (product.stok > 10)
                                          Text('Stok: ${product.stok}', style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w600))
                                        else if (product.stok > 0)
                                          Text('Stok: ${product.stok}', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600))
                                        else
                                          const Text('Stok Habis', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF5F6FA),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            product.kategori.nama,
                                            style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Rating
                                        Icon(Icons.star, color: Colors.amber, size: 18),
                                        const SizedBox(width: 2),
                                        Text(
                                          product.rating.toStringAsFixed(1),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(width: 4),
                                        Text('(${product.jumlahUlasan} ulasan)', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Chat admin
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF7C3AED)),
                                onPressed: () {
                                  // TODO: Implementasi chat admin
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fitur chat admin coming soon!'),
                                      backgroundColor: Color(0xFFE9D8FD),
                                      behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                            ],
                          ),
                          const Divider(height: 32),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                _ExpandableDescription(text: product.deskripsi),
                              ],
                            ),
                          ),
                if (_isLoadingRelated)
                  const Center(child: CircularProgressIndicator()),
                if (!_isLoadingRelated && _relatedProducts.isNotEmpty) ...[
                            const SizedBox(height: 32),
                  const Text('Produk Satu Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                              height: 170,
                              child: Stack(
                                children: [
                                  ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _relatedProducts.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final p = _relatedProducts[idx];
                                      return Container(
                                        width: 120,
                          child: ProductCard(
                            product: p,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(productId: p.id),
                                ),
                              );
                            },
                            compact: true,
                          ),
                        );
                      },
                                  ),
                                  // Swipe indicator kiri
                                  if (_relatedProducts.length > 2)
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 28,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [Colors.white, Colors.white.withOpacity(0.0)],
                                          ),
                                        ),
                                        child: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF7C3AED)),
                                      ),
                                    ),
                                  // Swipe indicator kanan
                                  if (_relatedProducts.length > 2)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 28,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerRight,
                                            end: Alignment.centerLeft,
                                            colors: [Colors.white, Colors.white.withOpacity(0.0)],
                                          ),
                                        ),
                                        child: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF7C3AED)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                          if (!_isLoadingRelated && _relatedProducts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: Text('Tidak ada produk lain di kategori ini', style: TextStyle(color: Color(0xFF9E9E9E)))),
                            ),
                        ],
                    ),
                  ),
                ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      final isLoading = cart.isLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _isInCart
                              ? ElevatedButton(
                                  key: const ValueKey('incart'),
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF9E9E9E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 2,
                                  ),
                                  child: const Text('Sudah di Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
                                )
                              : ElevatedButton(
                                  key: const ValueKey('addcart'),
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          setState(() => _isInCart = true);
                                          await Future.delayed(const Duration(milliseconds: 300)); // animasi dummy
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: const [
                                                    Icon(Icons.check_circle, color: Color(0xFF22C55E)),
                                                    SizedBox(width: 8),
                                                    Text('Produk berhasil ditambahkan ke keranjang!'),
                                                  ],
                                                ),
                                                backgroundColor: Color(0xFFE9D8FD),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                          await cart.addToCart(product.id, 1);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF7C3AED),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 4,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('Tambah ke Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String text;
  const _ExpandableDescription({required this.text});
  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool expanded = false;
  static const int maxLines = 5;
  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.split(' ').length > 30 || widget.text.length > 180;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: expanded ? null : maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Color(0xFF22223B)),
        ),
        if (isLong && !expanded)
          TextButton(
            onPressed: () => setState(() => expanded = true),
            child: const Text('Lihat Selengkapnya'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
          ),
        if (isLong && expanded)
          TextButton(
            onPressed: () => setState(() => expanded = false),
            child: const Text('Sembunyikan'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
          ),
      ],
    );
  }
} 