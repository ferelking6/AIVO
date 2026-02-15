import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aivo/providers/wishlist_provider.dart';
import 'package:aivo/providers/auth_provider.dart';

class WishlistButton extends StatefulWidget {
  final String productId;
  final double size;
  final Color? heartColor;
  final Function? onToggle;

  const WishlistButton({
    super.key,
    required this.productId,
    this.size = 24,
    this.heartColor,
    this.onToggle,
  });

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleWishlist() async {
    final authProvider = context.read<AuthProvider>();
    final wishlistProvider = context.read<WishlistProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save items')),
      );
      return;
    }

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    final success = await wishlistProvider.toggleWishlist(
      userId: authProvider.user!.id,
      productId: widget.productId,
    );

    if (success) {
      widget.onToggle?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wishlistProvider.isInWishlist(widget.productId)
                ? 'Added to Wishlist'
                : 'Removed from Wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final isInWishlist =
            wishlistProvider.isInWishlist(widget.productId);

        return ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.2)
              .animate(_animationController),
          child: IconButton(
            onPressed: _toggleWishlist,
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              size: widget.size,
              color: widget.heartColor ?? (isInWishlist ? Colors.red : Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
