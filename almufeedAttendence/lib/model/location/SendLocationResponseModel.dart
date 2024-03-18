import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class SendLocationResponseModel {
  final bool result;

  SendLocationResponseModel({
    required this.result});

  factory SendLocationResponseModel.fromJson(Map<String, dynamic> json) {
    return SendLocationResponseModel(
        result: json['result']
    );
  }

/*factory LoginResponse.fromJson(Map<String, dynamic> jsonData) =>
      _$LoginResponseFromJson(jsonData);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
*/
}