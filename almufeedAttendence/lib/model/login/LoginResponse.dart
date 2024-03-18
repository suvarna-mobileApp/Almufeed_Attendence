import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';
part 'Login_Response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String resourceId;
  final String userName;
  final String password;
  final bool result;

  LoginResponse({
    required this.resourceId,
    required this.userName,
    required this.password,
    required this.result,});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      resourceId: json['ResourceID'],
      userName: json['userName'],
      password: json['password'],
      result: json['result'],
    );
  }

  /*factory LoginResponse.fromJson(Map<String, dynamic> jsonData) =>
      _$LoginResponseFromJson(jsonData);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
*/
}