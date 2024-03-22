import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Colours.dart';
import '../dashboard/Dashboard.dart';
import '../model/attendence/GetAttendenceListViewModel.dart';

class MyAttendence extends StatelessWidget {
  const MyAttendence({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyAttendenceExample(),
    );
  }
}

class MyAttendenceExample extends StatefulWidget {
  const MyAttendenceExample({super.key});

  @override
  State<MyAttendenceExample> createState() =>
      _MyAttendenceExampleState();
}

class _MyAttendenceExampleState extends State<MyAttendenceExample> with TickerProviderStateMixin {
  bool isLoading = false;
  late List<CheckInList> attendneceList;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    attendneceList = [];
    getToken();
  }

  void getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      final String token = prefs.getString('token').toString();
      final String userName = prefs.getString('username').toString();
      String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      print(token);
      getAttendenceList(userName,token,formattedDate);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: ColorConstants.kPrimaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(),
              ),
            );
          },
        ),
        title: const Text(
          'My Attendence',
          style: TextStyle(
            color: ColorConstants.kPrimaryColor,
            fontFamily: 'Montserrat',// Text color
            fontSize: 18, // Font size
            fontWeight: FontWeight.bold, // Font weight
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            color: ColorConstants.kPrimaryColor,
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: isLoading?
      progressBar(context) : ListView.builder(
        itemCount: attendneceList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
            elevation: 4,
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0,20.0,0.0,0.0),
                  child: Text(
                    "Location : " + attendneceList[index].name.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 2),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0,5.0,0.0,0.0),
                  child: Text(
                    "Status : " + attendneceList[index].status.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 2),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0,5.0,0.0,20.0),
                  child: Text(
                    "Date and Time : " + attendneceList[index].date.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ), //onTap: () => onTap(attendneceList[index]),
          );
        },
      ),
    );
  }

  double getTextSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (screenSize.shortestSide < 600) {
      // This is a phone (iPhone or similar)
      return 16; // Adjust the margin for iPhones
    } else {
      // This is a tablet (iPad or similar)
      return 22; // Adjust the margin for iPads
    }
  }

  Widget progressBar(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
          color: ColorConstants.kPrimaryColor,
          strokeWidth: 3,
        ));
  }

  getAttendenceList(String empId,String token,String date) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': token
    };
    var data = json.encode({
      "_employeeId": empId,
      "_date": date
    });
    var dio = Dio();
    var response = await dio.request(
      'https://iye-live.operations.dynamics.com/api/services/AHSMobileServices/AHSMobileService/getCheckHistory',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      GetAttendenceListViewModel data = GetAttendenceListViewModel.fromJson(response.data);
      if(data.checkInList != null){
        attendneceList = data.checkInList!;
        print(attendneceList);
      }else{
        Fluttertoast.showToast(
            msg: "No Data Found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.statusMessage);
    }
  }

  Map<String, List<CheckInList>> parseData(Map<String, dynamic> jsonData) {
    Map<String, List<CheckInList>> result = {};

    jsonData.forEach((key, value) {
      List<CheckInList> dataList = [];
      print('Key: $key, Value: $value');
      for (var item in value) {
        dataList.add(CheckInList.fromJson(item));
      }
      result[key] = dataList;
    });
    return result;
  }
}
