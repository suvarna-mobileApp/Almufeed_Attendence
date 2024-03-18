import 'package:http/io_client.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class viewprofile {
  final String Name;
  final String designation;
  final String department;
  final String photo;
  final String mobilenumber;
  final String emailid;
  final String passport;
  final String medical;
  final String visa;
  final String emiratedid;

  viewprofile({
    required this.Name,
    required this.designation,
    required this.department,
    required this.photo,
    required this.mobilenumber,
    required this.emailid,
    required this.passport,
    required this.medical,
    required this.visa,
    required this.emiratedid,});

  factory viewprofile.fromJson(Map<String, dynamic> json) {
    return viewprofile(
      Name: json['Name'],
      designation: json['designation'],
      department: json['department'],
      photo: json['photo'],
      mobilenumber: json['mobilenumber'],
      emailid: json['emailid'],
      passport: json['passport'],
      medical: json['medical'],
      visa: json['visa'],
      emiratedid: json['emiratedid']
    );
  }

/*factory LoginResponse.fromJson(Map<String, dynamic> jsonData) =>
      _$LoginResponseFromJson(jsonData);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
*/
}