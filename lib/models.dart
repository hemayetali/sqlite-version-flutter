class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  Product({required this.id, required this.name, required this.price, required this.imageUrl, required this.description});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'],
        price: map['price'],
        imageUrl: map['imageUrl'],
        description: map['description'],
      );
}

class UserData {
  final String uid;
  final String email;

  UserData({required this.uid, required this.email});

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
      };

  factory UserData.fromMap(Map<String, dynamic> map) => UserData(
        uid: map['uid'],
        email: map['email'],
      );
}

class CartItem {
  final int id;
  final int productId;
  final int quantity;

  CartItem({required this.id, required this.productId, required this.quantity});

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'quantity': quantity,
      };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
        id: map['id'],
        productId: map['productId'],
        quantity: map['quantity'],
      );
}
