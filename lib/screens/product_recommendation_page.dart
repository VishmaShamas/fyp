import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../liked_products_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductRecommendationPage extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ProductRecommendationPage({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkScaffoldColor,
        title: const Text(
          'Product Recommendation',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.recommend, color: Colors.white54, size: 50),
                  const SizedBox(height: 12),
                  const Text(
                    'No recommendations found',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    parentContext: context,
                  );
                },
              ),
            ),
    );
  }
}



class ProductCard extends StatelessWidget {
  final Map<String, dynamic>? product;
  final BuildContext parentContext;

  const ProductCard({
    super.key,
    required this.product,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    if (product == null || product is! Map<String, dynamic>) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Invalid product',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final priceWidget = _buildPriceWidget(product!);

    return GestureDetector(
      onTap: () => Navigator.push(
        parentContext,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product!),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  color: Colors.black.withOpacity(0.1),
                ),
                child: product!['imageUrl'] != null
                    ? Image.network(
                        product!['imageUrl'].toString(),
                        fit: BoxFit.scaleDown,
                        errorBuilder: (_, __, ___) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!['title']?.toString() ?? 'No Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    product!['brand']?.toString() ?? 'No Brand',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  // Only show price if present
                  ...[
                  const SizedBox(height: 6),
                  priceWidget,
                ],
                  // If price is null, the card ends here (shorter card)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(Icons.image_not_supported,
          color: Colors.white24, size: 40),
    );
  }

  Widget _buildPriceWidget(Map<String, dynamic> product) {
  final priceRaw = product['price'];
  final discountRaw = product['discount_price'];

  final price = num.tryParse(priceRaw?.toString() ?? '');
  final discountPrice = num.tryParse(discountRaw?.toString() ?? '');

  if (price == null) {
    return const Text(
      'Prices not available',
      style: TextStyle(
        color: Colors.white54, // Grey
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  if (discountPrice != null && discountPrice > 0 && discountPrice < price) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Rs. $discountPrice',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Rs. $price',
          style: const TextStyle(
            color: Colors.white54,
            decoration: TextDecoration.lineThrough,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  return Text(
    'Rs. $price',
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}
}



class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late bool _isLiked;
  final LikedProductsManager _manager = LikedProductsManager();

  @override
  void initState() {
    super.initState();
    _isLiked = _manager.isLiked(widget.product);
    _manager.addListener(_onLikedChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onLikedChanged);
    super.dispose();
  }

  void _onLikedChanged() {
    setState(() {
      _isLiked = _manager.isLiked(widget.product);
    });
  }

  void _toggleLike() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    // Handle unauthenticated user (optional)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in to like products.')),
    );
    return;
  }

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.email);
  final likedRef = userRef.collection('likedProducts');
  final productId = widget.product['id']?.toString();

  if (_isLiked) {
    // Unlike: Remove from Firestore
    if (productId != null) {
      await likedRef.doc(productId).delete();
    }
    _manager.unlikeProduct(widget.product);
  } else {
    // Like: Save in Firestore
    if (productId != null) {
      await likedRef.doc(productId).set(widget.product);
    }
    _manager.likeProduct(widget.product);
  }
}


  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.product['discount_price'] != null && widget.product['discount_price'].toString().isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkScaffoldColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.product['brand'] ?? '',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  widget.product['imageUrl'] ?? '',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.samiDarkColor,
                    child: const Icon(Icons.broken_image, color: Colors.white, size: 80),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.product['title'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Brand & Category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text(
                    widget.product['brand'] ?? '',
                    style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: AppColors.lightAccentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.product['category'] ?? '',
                      style: TextStyle(color: AppColors.lightAccentColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  if (hasDiscount) ...[
                    Text(
                      'Rs. ${widget.product['price']}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Rs. ${widget.product['discount_price']}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Rs. ${widget.product['price']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.product['description'] ?? '',
                style: TextStyle(color: AppColors.greyColor, fontSize: 15),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.samiDarkColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Row(
  children: [
    Expanded( // 👈 This makes the button take up remaining space
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16), // Optional: consistent height
        ),
        onPressed: () async {
  final url = widget.product['url']?.toString() ?? '';
  if (url.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product URL not available')),
    );
    return;
  }
  launch(url);
  // final uri = Uri.tryParse(url);
  // if (uri != null && await canLaunchUrl(uri)) {
  //   await launchUrl(uri, mode: LaunchMode.externalApplication);
  // } else {
  //   if (!context.mounted) return;
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Could not open the link')),
  //   );
  // }
},


        child: const Text(
          'Buy Now',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const SizedBox(width: 12), // 👈 Optional spacing between button and icon
    IconButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_border,
        color: _isLiked ? Colors.red : Colors.white,
      ),
      onPressed: _toggleLike,
      tooltip: _isLiked ? 'Unlike' : 'Like',
    ),
  ],
),

        ),
      ),
    );
  }
}
