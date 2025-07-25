// To parse this JSON data, do
//
//     final paymentMethodModel = paymentMethodModelFromJson(jsonString);

import 'dart:convert';

PaymentMethodModel paymentMethodModelFromJson(String str) =>
    PaymentMethodModel.fromJson(json.decode(str));

String paymentMethodModelToJson(PaymentMethodModel data) =>
    json.encode(data.toJson());

class PaymentMethodModel {
  final bool status;
  final String message;
  final List<PaymentMethod> data;

  PaymentMethodModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel(
        status: json["status"],
        message: json["message"],
        data: List<PaymentMethod>.from(
            json["data"].map((x) => PaymentMethod.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final int fee;
  final String icon;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.fee,
    required this.icon,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        fee: json["fee"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "fee": fee,
        "icon": icon,
      };
} 