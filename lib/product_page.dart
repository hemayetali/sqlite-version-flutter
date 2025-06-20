import 'package:flutter/material.dart';
import 'models.dart';
import 'db_helper.dart';
import 'firebase_helper.dart';

class ProductPage extends StatefulWidget {
  final VoidCallback onCartTap;
  const ProductPage({super.key, required this.onCartTap});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    // Try Firebase first, fallback to SQLite
    try {
      _products = await FirebaseHelper.fetchProducts();
    } catch (_) {
      _products = await DBHelper().getProducts();
    }
    setState(() { _loading = false; });
  }

  void _addToCart(Product product) async {
    // Add to local cart
    await DBHelper().insertCartItem(CartItem(id: product.id, productId: product.id, quantity: 1));
    // Add to Firebase cart if logged in
    final userId = DBHelper.currentUserId;
    if (userId != null) {
      // Optionally sync to Firestore or handle user-specific cart logic
      // await FirebaseHelper.addCartItem(userId.toString(), CartItem(id: product.id, productId: product.id, quantity: 1));
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: widget.onCartTap),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, i) {
                final p = _products[i];
                return Card(
                  child: ListTile(
                    leading: Image.network(p.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                    title: Text(p.name),
                    subtitle: Text(p.description),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(' 24${p.price.toStringAsFixed(2)}'),
                        IconButton(icon: const Icon(Icons.add_shopping_cart), onPressed: () => _addToCart(p)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
