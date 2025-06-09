import 'package:flutter/material.dart';
import 'models.dart';
import 'db_helper.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    try {
      final userId = DBHelper.currentUserId;
      if (userId != null) {
        // Optionally sync to Firestore or handle user-specific cart logic
        // _cartItems = await FirebaseHelper.fetchCart(userId.toString());
        _cartItems = await DBHelper().getCartItems();
      } else {
        _cartItems = await DBHelper().getCartItems();
      }
    } catch (_) {
      _cartItems = await DBHelper().getCartItems();
    }
    setState(() { _loading = false; });
  }

  void _clearCart() async {
    final userId = DBHelper.currentUserId;
    if (userId != null) {
      // Optionally sync to Firestore or handle user-specific cart logic
      // await FirebaseHelper.clearCart(userId.toString());
    }
    await DBHelper().clearCart();
    await _fetchCart();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart cleared')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _clearCart),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, i) {
                    final item = _cartItems[i];
                    return ListTile(
                      title: Text('Product ID: ${item.productId}'),
                      subtitle: Text('Quantity: ${item.quantity}'),
                    );
                  },
                ),
    );
  }
}
