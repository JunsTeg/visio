// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  isVerified: json['isVerified'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  roles:
      (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'isVerified': instance.isVerified,
  'createdAt': instance.createdAt.toIso8601String(),
  'roles': instance.roles,
};

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
};
