import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/product/data/product_model.dart';
import '../../core/constants.dart';
import 'package:provider/provider.dart';
import '../../features/cart/provider/cart_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool compact;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.compact = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  bool isWishlisted = false; // Tambahkan sebagai state

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  Future<void> _handleAddToCart(BuildContext context) async {
    setState(() => _isLoading = true);
    final cart = Provider.of<CartProvider>(context, listen: false);
    try {
      await cart.addToCart(widget.product.id, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil ditambahkan ke keranjang!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.startsWith('Exception: ')) {
          msg = msg.replaceFirst('Exception: ', '');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final double imageSize = widget.compact ? 55 : 120;
    final double fontSize = widget.compact ? 10 : 14;
    final double priceFontSize = widget.compact ? 11 : 15;
    final double buttonHeight = widget.compact ? 18 : 28;
    final double buttonFontSize = widget.compact ? 9 : 12;
    // Dummy badge & rating
    final String? badge = widget.product.id % 3 == 0 ? 'Baru' : (widget.product.id % 3 == 1 ? 'Diskon' : null);
    final double rating = 4.5; // Dummy rating
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(widget.compact ? 10 : 16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Bagian gambar, badge, wishlist
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(widget.compact ? 10 : 16),
                              topRight: Radius.circular(widget.compact ? 10 : 16),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CachedNetworkImage(
                                imageUrl: widget.product.imageUrl,
                                fit: BoxFit.cover,
                                width: imageSize,
                                height: imageSize,
                                placeholder: (context, url) => Container(
                                  color: AppColors.lightGrey,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.lightGrey,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.grey,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Wishlist button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isWishlisted = !isWishlisted;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    backgroundColor: const Color(0xFFFFE3E3), // Soft red
                                    duration: const Duration(seconds: 2),
                                    content: Row(
                                      children: [
                                        Icon(
                                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                                          color: const Color(0xFFD32F2F),
                                        ),
                                        const SizedBox(width: 10),
                                        const Expanded(child: Text('Wishlist coming soon!', style: TextStyle(color: Color(0xFFD32F2F), fontFamily: 'Poppins'))),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                                  color: isWishlisted ? Colors.redAccent : AppColors.primaryPurple,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          // Badge
                          if (badge != null)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badge == 'Diskon' ? Colors.redAccent : AppColors.primaryPurple,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  badge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: widget.compact ? 2 : 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: widget.compact ? 3 : 10),
                        child: Text(
                          widget.product.nama,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!widget.compact) ...[
                        SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            widget.product.formattedPrice,
                            style: TextStyle(
                              fontSize: priceFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        // Rating
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.darkGrey,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text('Terjual 100+', style: TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Poppins')),
                            ],
                          ),
                        ),
                        SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: widget.product.stok <= 0
                                ? ElevatedButton(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.grey,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      textStyle: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    child: const Text('Stok Habis'),
                                  )
                                : ElevatedButton(
                                    onPressed: _isLoading ? null : () async {
                                      // Animasi add-to-cart: produk "melompat" ke cart
                                      await _animationController.forward();
                                      await _handleAddToCart(context);
                                      _animationController.reverse();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryPurple,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      textStyle: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('Tambah'),
                                  ),
                          ),
                        ),
                      ],
                      SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
