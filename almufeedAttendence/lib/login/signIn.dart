import 'dart:async';
import 'dart:convert';
import 'package:almufeedattendence/model/login/LoginResponse.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Colours.dart';
import '../dashboard/Dashboard.dart';
import '../model/attendence/LocationViewModel.dart';
import '../model/login/AccessToken.dart';

class signIn extends StatelessWidget {
  const signIn({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: signInExample(),
    );
  }
}

class signInExample extends StatefulWidget {
  const signInExample({super.key});

  @override
  State<signInExample> createState() =>
      _signInExampleExampleState();
}

class _signInExampleExampleState extends State<signInExample> with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  late LoginResponse loginResponse;
  bool isLoading = false;
  List<String> latitude = List<String>.of([]);
  List<String> longitude = List<String>.of([]);
  List<String> buildingName = List<String>.of([]);

  @override
  void initState() {
    super.initState();

    _requestNotificationPermission();
  }


  void _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permission granted");
      // Handle permission granted
    } else {
      print("Notification permission denied");
      // Handle permission denied
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double halfScreenHeight = screenHeight / 2;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: isLoading?
      progressBar(context) :
      Container(
        color: ColorConstants.litegrey,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: halfScreenHeight,
              child:  ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0)),
                child: Container(
                  color: ColorConstants.kPrimaryColor,
                  /* child: Image.asset(
                'assets/image/bg.jpg',
                fit: BoxFit.cover,
              ),*/
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0),
              child: Image.asset(
                'assets/image/almufeed_splash.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Center(
              child: Container(
                width: double.infinity,
                height: halfScreenHeight,
                margin: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                ),
                child:  ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0,0.0,20.0,0.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: new Text("User Name",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0,10.0,20.0,0.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: _buildTextFieldWIthoutBorder(
                            controller: nameController,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0,20.0,20.0,0.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: new Text("Password",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0,10.0,20.0,0.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: _buildTextFieldWIthoutBorderPassword(
                            controller: passwordController,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0,20.0,20.0,0.0),
                        child: Container(
                            child: _buttons('Login', context)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildTextFieldWIthoutBorder({
    required TextEditingController controller,
    TextInputType? inputType,
    int? maxLines,
  }) {
    return Container(
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        maxLines: 1,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black,width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black,width: 0.5),
          ),
        ),
      ),
    );
  }
  Widget _buildTextFieldWIthoutBorderPassword({
    required TextEditingController controller,
    TextInputType? inputType,
    int? maxLines,
  }) {
    return Container(
      child: TextField(
        obscureText: true,
        controller: controller,
        keyboardType: inputType,
        textInputAction: TextInputAction.done,
          maxLines: 1,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black,width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black,width: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buttons(name, BuildContext context) {
    return Center(
        child: ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
                ElevatedButton(
                  child: new Text(name,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    primary: ColorConstants.kPrimaryColor,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      Autorization(nameController.value.text,passwordController.value.text);
                    });
                  },
                ),
          ],
        ));
  }

  Widget progressBar(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
          color: ColorConstants.kPrimaryColor,
          strokeWidth: 3,
        ));
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

  LoginSubmit(String userName, String password, String token) async {
    var headers = {
      'Content-Type': 'text/plain',
      'Authorization': token
    };
    var data = '''{\r\n    "_userName": "tab1",\r\n    "_password": "tab1"\r\n}''';
    Map<String, dynamic> jsonData = jsonDecode(data);

    // Add a new key-value pair to the Map
    jsonData['_userName'] = userName;
    jsonData['_password'] = password;
    // Convert the Map back to a JSON string
    String newData = jsonEncode(jsonData);

    print(newData);
    var dio = Dio();
    var response = await dio.request(
      'https://iye-live.operations.dynamics.com/api/services/AHSMobileServices/AHSMobileService/AHSAuthentication',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: newData,
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = true;
      });
      LoginResponse data = LoginResponse.fromJson(response.data);
      print(data.result);
      if(data.result == true){
        prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', userName);
        await prefs.setBool('firstLogin', true);
        await prefs.setBool('punchflag', false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(),
          ),
        );
      }else{
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Incorrect Username or Password",
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

  LocationInfo(String token, String userName, String password) async {
    var headers = {
      'Content-Type': 'text/plain',
      'Authorization': token
    };

    var dio = Dio();
    var response = await dio.request(
      'https://iye-live.operations.dynamics.com/api/services/AHSMobileServices/AHSMobileService/getLocationAll',
      options: Options(
        method: 'POST',
        headers: headers,
      )
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = true;
      });
      LocationViewModel data = LocationViewModel.fromJson(response.data);
      print(data.checkInList);
      if(data.checkInList != null){
        prefs = await SharedPreferences.getInstance();
        latitude = List<String>.of([]);
        longitude = List<String>.of([]);
        buildingName = List<String>.of([]);

        for (int i = 0; i < data.checkInList!.length; i++) {
          String locLat = data.checkInList![i].latitude.toString();
          String locLong = data.checkInList![i].longitude.toString();
          String buildName = data.checkInList![i].name.toString();
          latitude.add(locLat);
          longitude.add(locLong);
          buildingName.add(buildName);
          //print('user reached to the destination...' + data.checkInList![i].name.toString() + " datalist " + data.checkInList!.length.toString());
        }
       // print('user reached to the destination...' + buildingName.length.toString() + " datalist " + data.checkInList!.length.toString());
        await prefs.setStringList('locationLat', latitude);
        await prefs.setStringList('locationLong', longitude);
        await prefs.setStringList('locationName', buildingName);
      }else{
        await prefs.setStringList('locationLat', []);
        await prefs.setStringList('locationLong', []);
        await prefs.setStringList('locationName', []);
      }
      Timer(Duration(seconds: 1), () {
        LoginSubmit(userName, password,token);
      });
    }
  }

  Autorization(String userName, String password) async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var data = {
      'client_id': '7d2f26f6-2e67-4299-9abd-fbac27deff25',
      'client_secret': 'rcI8Q~eugdoR2M0Yx8_gkTPqqyPyT.sn9ab3BdeF',
      'grant_type': 'client_credentials',
      'resource': 'https://iye-live.operations.dynamics.com'
    };
    var dio = Dio();
    var response = await dio.request(
      'https://login.microsoftonline.com/8bd1367c-efa4-40b4-acac-9f3e4c82000b/oauth2/token',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      AccessToken data = AccessToken.fromJson(response.data);
      print(data.accessToken);
      prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', "Bearer " + data.accessToken);

      Timer(Duration(seconds: 1), () {
        LocationInfo("Bearer " + data.accessToken,userName,password);
      });

    } else {
      print(response.statusMessage);
    }
  }

}