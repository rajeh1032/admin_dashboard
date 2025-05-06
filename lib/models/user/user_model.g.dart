// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      json['id'] as String,
      json['name'] as String,
      json['email'] as String,
      photoURL: json['photoURL'] as String?,
      address: json['address'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      phoneNumber: json['phoneNumber'] as String,
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'photoURL': instance.photoURL,
      'address': instance.address,
      'role': _$UserRoleEnumMap[instance.role]!,
      'phoneNumber': instance.phoneNumber,
      'status': _$UserStatusEnumMap[instance.status]!,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.user: 'user',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
  UserStatus.blocked: 'blocked',
};
