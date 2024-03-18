import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class LocationViewModel {
  String? id;
  List<CheckInList>? checkInList;

  LocationViewModel({this.id, this.checkInList});

  LocationViewModel.fromJson(Map<String, dynamic> json) {
    id = json['$id'];
    if (json['CheckInList'] != null) {
      checkInList = <CheckInList>[];
      json['CheckInList'].forEach((v) {
        checkInList!.add(new CheckInList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$id'] = this.id;
    if (this.checkInList != null) {
      data['CheckInList'] = this.checkInList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CheckInList {
  String? id;
  double? latitude;
  double? longitude;
  String? name;

  CheckInList({this.id, this.latitude, this.longitude, this.name});

  CheckInList.fromJson(Map<String, dynamic> json) {
    id = json['$id'];
    latitude = double.parse(json['Date']);
    longitude = double.parse(json['Status']);
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$id'] = this.id;
    data['Date'] = this.latitude!.toDouble();
    data['Status'] = this.longitude!.toDouble();
    data['Name'] = this.name;
    return data;
  }
}