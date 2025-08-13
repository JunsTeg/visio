import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? role; // 'user' ou 'seller'
  final String? avatarUrl;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.role,
    this.avatarUrl,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
