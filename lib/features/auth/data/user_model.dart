class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? json['nama'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? json['peran'] ?? 'pelanggan',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
    };
  }
} 