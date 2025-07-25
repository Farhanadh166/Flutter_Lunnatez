import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/home_provider.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/category_item.dart';
import '../../../shared/widgets/product_skeleton.dart';
import '../../../core/constants.dart';
import '../../product/data/product_model.dart';
import '../../product/data/category_model.dart';
import '../../product/presentation/product_detail_page.dart';
import '../../auth/data/auth_service.dart';
import '../../profile/data/profile_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _userName = 'User';
  String _photoUrl = '';
  String _sortBy = 'terbaru';
  int? _minPrice;
  int? _maxPrice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initializeData();
    });
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final token = await AuthService.getToken();
    if (token != null) {
      try {
        final profile = await ProfileService.getProfile(token);
        if (profile['name'] != null && profile['name'].toString().isNotEmpty) {
          setState(() {
            _userName = profile['name'];
            _photoUrl = profile['photo_url'] ?? '';
          });
        }
      } catch (e) {
        // fallback: tidak update nama
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<HomeProvider>().searchProducts(query);
  }

  void _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String tempSort = _sortBy;
        final minController = TextEditingController(text: _minPrice?.toString() ?? '');
        final maxController = TextEditingController(text: _maxPrice?.toString() ?? '');
        return AlertDialog(
          title: const Text('Filter Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tempSort,
                decoration: const InputDecoration(labelText: 'Urutkan'),
                items: const [
                  DropdownMenuItem(value: 'terbaru', child: Text('Terbaru')),
                  DropdownMenuItem(value: 'terlama', child: Text('Terlama')),
                  DropdownMenuItem(value: 'termurah', child: Text('Harga Termurah')),
                  DropdownMenuItem(value: 'termahal', child: Text('Harga Termahal')),
                ],
                onChanged: (v) => tempSort = v ?? 'terbaru',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga Minimum'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga Maksimum'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'sort': tempSort,
                  'min': int.tryParse(minController.text),
                  'max': int.tryParse(maxController.text),
                });
              },
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        _sortBy = result['sort'] ?? 'terbaru';
        _minPrice = result['min'];
        _maxPrice = result['max'];
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    final provider = context.read<HomeProvider>();
    List<Product> filtered = List.from(provider.products);
    // Filter harga
    if (_minPrice != null) {
      filtered = filtered.where((p) => p.harga >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      filtered = filtered.where((p) => p.harga <= _maxPrice!).toList();
    }
    // Urutkan
    switch (_sortBy) {
      case 'terbaru':
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'terlama':
        filtered.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'termurah':
        filtered.sort((a, b) => a.harga.compareTo(b.harga));
        break;
      case 'termahal':
        filtered.sort((a, b) => b.harga.compareTo(a.harga));
        break;
    }
    provider.setFilteredProducts(filtered);
  }

  Future<void> openWhatsAppAdmin() async {
    final phone = '6281378132117'; // Nomor admin (format internasional, tanpa +)
    final message = Uri.encodeComponent('Halo Admin, saya ingin bertanya mengenai produk Lunnatezz.');
    final url = Uri.parse('https://wa.me/$phone?text=$message');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: provider.refresh,
              color: AppColors.primaryPurple,
              displacement: 36,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildPromoBanner()),
                  SliverToBoxAdapter(child: _buildCategories()),
                  if (provider.isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ProductSkeleton(),
                          childCount: 6,
                        ),
                      ),
                    )
                  else if (provider.error.isNotEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Terjadi kesalahan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGrey,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.error,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.refresh(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Coba Lagi',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (provider.filteredProducts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/empty_state.png',
                              width: 120,
                              height: 120,
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Oops, produk tidak ditemukan!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryPurple,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Coba ubah kata kunci atau pilih kategori lain ya~',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55, // dari 0.7
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = provider.filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () => _onProductTap(product),
                              onAddToCart: () => _onAddToCart(product),
                            );
                          },
                          childCount: provider.filteredProducts.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openWhatsAppAdmin,
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Chat Admin'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.lightGrey,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Lunnatez
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/logo_tr.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Judul dan greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LUNNATEZ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                            fontFamily: 'Poppins',
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hai, $_userName!',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryPurple,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Avatar user
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.lightPurple,
                      backgroundImage: _photoUrl.isNotEmpty
                          ? NetworkImage(_photoUrl)
                          : const AssetImage('assets/avatar_placeholder.png') as ImageProvider,
                      child: Container(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Cart button
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search Bar dengan shadow dan filter
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightPurple),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: 'Cari produk aksesoris...',
                          prefixIcon: Icon(Icons.search, color: AppColors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintStyle: TextStyle(
                            color: AppColors.grey,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: const Icon(Icons.filter_alt_rounded, color: AppColors.primaryPurple),
                        onPressed: _showFilterDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  // Promo banner auto-slide looping dengan fade
  Widget _buildPromoBanner() {
    final List<String> banners = [
      'assets/banner1.png',
      'assets/banner2.png',
      'assets/banner3.jpeg',
    ];
    return _LoopingFadeBanner(banners: banners);
  }

  void _onCategoryTap(int? categoryId) {
    context.read<HomeProvider>().filterByCategory(categoryId);
  }

  void _onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  void _onAddToCart(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFDEF7EC),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF2D9C5A)),
            SizedBox(width: 10),
            Expanded(child: Text('${product.nama} ditambahkan ke keranjang', style: TextStyle(color: Color(0xFF2D9C5A), fontFamily: 'Poppins'))),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCategories) {
          return Container(
            height: 72,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          );
        }

        return Container(
          height: 72,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // All Categories
              CategoryItem(
                category: Category(
                  id: 0,
                  nama: 'Semua',
                ),
                isSelected: provider.selectedCategoryId == null,
                onTap: () => _onCategoryTap(null),
              ),
              ...provider.categories.cast<Category>().map((category) => CategoryItem(
                category: category,
                isSelected: provider.selectedCategoryId == category.id,
                onTap: () => _onCategoryTap(category.id),
              )),
            ],
          ),
        );
      },
    );
  }
}

// Widget looping banner dengan fade
class _LoopingFadeBanner extends StatefulWidget {
  final List<String> banners;
  const _LoopingFadeBanner({required this.banners});

  @override
  State<_LoopingFadeBanner> createState() => _LoopingFadeBannerState();
}

class _LoopingFadeBannerState extends State<_LoopingFadeBanner> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late List<String> _banners;

  @override
  void initState() {
    super.initState();
    _banners = widget.banners;
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.value = 1.0;
    _startAutoSlide();
  }

  void _startAutoSlide() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) break;
      await _fadeController.reverse();
      if (!mounted) break;
      setState(() {
        _currentPage = (_currentPage + 1) % _banners.length;
      });
      await _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                _banners[_currentPage],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom refresh indicator dengan logo Lunnatez berputar
class CustomRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  const CustomRefreshIndicator({super.key, required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primaryPurple,
      displacement: 36,
      notificationPredicate: (notification) => notification.depth == 0,
      child: child,
      // Custom indicator
      semanticsLabel: 'Refresh',
      semanticsValue: 'Pull to refresh',
      strokeWidth: 2.5,
      backgroundColor: Colors.white,
    );
  }
} 