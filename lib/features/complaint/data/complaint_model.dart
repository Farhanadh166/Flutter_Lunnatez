class Complaint {
  final int id;
  final int userId;
  final int orderId;
  final String reason;
  final String description;
  final String? photo;
  final String status;
  final String? response;
  final String createdAt;
  final String updatedAt;
  final User? user;
  final Order? order;

  Complaint({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.reason,
    required this.description,
    this.photo,
    required this.status,
    this.response,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.order,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      orderId: int.tryParse(json['order_id'].toString()) ?? 0,
      reason: json['reason']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      photo: json['photo']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      response: json['response']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'reason': reason,
      'description': description,
      'photo': photo,
      'status': status,
      'response': response,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user?.toJson(),
      'order': order?.toJson(),
    };
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Menunggu Review';
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'diterima':
        return '#4CAF50'; // Green
      case 'ditolak':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Gray
    }
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class Order {
  final int id;
  final String orderNumber;
  final String status;
  final double? totalAmount;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.totalAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: int.tryParse(json['id'].toString()) ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalAmount: json['total_amount'] != null 
          ? double.tryParse(json['total_amount'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'total_amount': totalAmount,
    };
  }
} 