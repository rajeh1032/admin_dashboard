import 'package:admin_dashboard/enums/user_role.dart';
import 'package:admin_dashboard/enums/user_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoURL;
  final String address;
  final String phoneNumber;
  final UserRole role;
  UserStatus status;

  UserModel(
    this.id,
    this.name,
    this.email, {
    this.photoURL,
    this.phoneNumber = "",
    required this.address,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
