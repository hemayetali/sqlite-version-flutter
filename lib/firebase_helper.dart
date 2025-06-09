import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'db_helper.dart';

/// FirebaseHelper now only uses Firestore for optional cloud sync.
/// All authentication, user, and cart logic is handled locally with SQLite.
class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth using local DB
  static Future<bool> signUp(String email, String password) async {
    // Try local DB first
    final dbSuccess = await DBHelper().signup(email, password);
    if (dbSuccess) {
      // Also add to Firestore
      await _firestore.collection('users').doc(email).set({
        'email': email,
        'password': password,
      });
      return true;
    } else {
      // Try Firestore (if user exists remotely but not locally)
      final doc = await _firestore.collection('users').doc(email).get();
      if (!doc.exists) return false;
      // Optionally sync to local DB
      await DBHelper().signup(email, password);
      return true;
    }
  }

  static Future<bool> signIn(String email, String password) async {
    // Try local DB first
    final dbSuccess = await DBHelper().login(email, password);
    if (dbSuccess) return true;
    // Try Firestore
    final doc = await _firestore.collection('users').doc(email).get();
    if (doc.exists && doc.data()?['password'] == password) {
      // Sync to local DB for offline
      await DBHelper().signup(email, password);
      return true;
    }
    return false;
  }

  static Future<void> signOut() async {
    DBHelper.currentUserId = null;
  }

  static int? get currentUserId => DBHelper.currentUserId;

  // Firestore
  static Future<void> addProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id.toString())
        .set(product.toMap());
  }

  static Future<List<Product>> fetchProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
  }

  static Future<void> addUser(UserData user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  static Future<UserData?> fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserData.fromMap(doc.data()!);
    }
    return null;
  }

  // The following Firestore methods are optional and not used in local DB-only mode.
  // You may use them for cloud sync if needed, but all user/cart/product logic is handled locally.
  static Future<void> addCartItem(String uid, CartItem item) async {
    // Optionally sync cart item to Firestore
  }

  static Future<List<CartItem>> fetchCart(String uid) async {
    // Optionally fetch cart from Firestore
    return [];
  }

  static Future<void> clearCart(String uid) async {
    // Optionally clear cart in Firestore
  }
}
