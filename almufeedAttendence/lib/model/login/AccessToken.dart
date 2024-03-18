import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AccessToken {
  final String tokenType;
  final String expiresIn;
  final String extExpiresIn;
  final String expiresOn;
  final String notBefore;
  final String resource;
  final String accessToken;

  AccessToken({
    required this.tokenType,
    required this.expiresIn,
    required this.extExpiresIn,
    required this.expiresOn,
    required this.notBefore,
    required this.resource,
    required this.accessToken,
  });

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      extExpiresIn: json['ext_expires_in'],
      expiresOn: json['expires_on'],
      notBefore: json['not_before'],
      resource: json['resource'],
      accessToken: json['access_token'],
    );
  }
}
