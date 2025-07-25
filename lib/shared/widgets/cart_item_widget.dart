import 'package:flutter/material.dart';
import '../../features/cart/data/cart_item.dart';
import 'package:provider/provider.dart';
import '../../features/cart/provider/cart_provider.dart';

class CartItemWidget extends StatefulWidget {
  final CartItem item;
  const CartItemWidget({super.key, required this.item});

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> with SingleTickerProviderStateMixin {
  late int _qty;
  late AnimationController _qtyAnimController;
  late Animation<double> _qtyScaleAnim;
  bool _isRemoved = false;

  @override
  void initState() {
    super.initState();
    _qty = widget.item.quantity;
    _qtyAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _qtyScaleAnim = Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)).animate(_qtyAnimController);
  }

  @override
  void didUpdateWidget(covariant CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.quantity != _qty) {
      _qty = widget.item.quantity;
      _qtyAnimController.forward(from: 0).then((_) => _qtyAnimController.reverse());
    }
  }

  @override
  void dispose() {
    _qtyAnimController.dispose();
    super.dispose();
  }

  void _showSnackbar(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color ?? const Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _removeWithAnim(CartProvider cart) async {
    setState(() => _isRemoved = true);
    await Future.delayed(const Duration(milliseconds: 350));
    cart.deleteCartItem(widget.item.id);
    _showSnackbar('Produk dihapus dari keranjang', color: const Color(0xFFEF4444));
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (_isRemoved) {
      return AnimatedOpacity(
        opacity: 0,
        duration: const Duration(milliseconds: 350),
        child: const SizedBox.shrink(),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.07),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.item.produk.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.produk.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF22223B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.produk.formattedPrice,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total: ${_formatPrice(widget.item.totalHarga)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: widget.item.quantity > 1
                              ? () {
                                  cart.updateCart(widget.item.id, widget.item.quantity - 1);
                                  _showSnackbar('Jumlah produk dikurangi');
                                }
                              : null,
                          color: widget.item.quantity > 1 ? const Color(0xFF7C3AED) : Colors.grey,
                        ),
                        ScaleTransition(
                          scale: _qtyScaleAnim,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${widget.item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () {
                            cart.updateCart(widget.item.id, widget.item.quantity + 1);
                            _showSnackbar('Jumlah produk ditambah');
                          },
                          color: const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () => _showDeleteDialog(context, cart),
                      color: Colors.red[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    )}';
  }

  void _showDeleteDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Item'),
          content: Text('Yakin ingin menghapus "${widget.item.produk.nama}" dari keranjang?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeWithAnim(cart);
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
} 