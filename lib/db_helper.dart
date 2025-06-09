import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DBHelper {
  static int? currentUserId;

  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'store_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, price REAL, imageUrl TEXT, description TEXT)''',
        );
        await db.execute(
          '''CREATE TABLE cart(id INTEGER PRIMARY KEY, productId INTEGER, quantity INTEGER)''',
        );
        await db.execute(
          '''CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, password TEXT)''',
        );
      },
    );
  }

  Future<void> insertProduct(Product product) async {
    final dbClient = await db;
    await dbClient.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getProducts() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<void> insertCartItem(CartItem item) async {
    final dbClient = await db;
    await dbClient.insert(
      'cart',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CartItem>> getCartItems() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('cart');
    return List.generate(maps.length, (i) => CartItem.fromMap(maps[i]));
  }

  Future<void> clearCart() async {
    final dbClient = await db;
    await dbClient.delete('cart');
  }

  // User signup
  Future<bool> signup(String email, String password) async {
    final dbClient = await db;
    try {
      await dbClient.insert('users', {'email': email, 'password': password});
      return true;
    } catch (e) {
      return false;
    }
  }

  // User login
  Future<bool> login(String email, String password) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }
}
