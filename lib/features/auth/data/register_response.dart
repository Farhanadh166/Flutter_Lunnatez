import 'user_model.dart';

class RegisterResponse {
  final bool success;
  final String message;
  final RegisterData? data;
  final Map<String, List<String>>? errors;

  RegisterResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
      errors: json['errors'] != null 
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) => MapEntry(
                key, 
                List<String>.from(value),
              )),
            )
          : null,
    );
  }
}

class RegisterData {
  final User user;
  final String token;
  final String tokenType;

  RegisterData({
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      user: User.fromJson(json['user']),
      token: json['token'],
      tokenType: json['token_type'],
    );
  }
} 