import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class GetAttendenceListViewModel {
  String? id;
  List<CheckInList>? checkInList;

  GetAttendenceListViewModel({this.id, this.checkInList});

  GetAttendenceListViewModel.fromJson(Map<String, dynamic> json) {
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
  String? date;
  String? status;
  String? name;

  CheckInList({this.id, this.date, this.status, this.name});

  CheckInList.fromJson(Map<String, dynamic> json) {
    id = json['$id'];
    date = json['Date'];
    status = json['Status'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$id'] = this.id;
    data['Date'] = this.date;
    data['Status'] = this.status;
    data['Name'] = this.name;
    return data;
  }
}