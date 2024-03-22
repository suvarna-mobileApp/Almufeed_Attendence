import 'dart:convert';
import 'package:almufeedattendence/dashboard/Dashboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Colours.dart';
import '../model/profile/viewprofile.dart';

class ViewProfile extends StatelessWidget {
  const ViewProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ViewProfileExample(),
    );
  }
}

class ViewProfileExample extends StatefulWidget {
  const ViewProfileExample({super.key});

  @override
  State<ViewProfileExample> createState() =>
      _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfileExample> with TickerProviderStateMixin {
  bool isLoading = false;
  String imageUser = "assets/image/icon_user_gold.png";
  String imageDoc = "assets/image/icon_doc_gold.png";
  String userName = "";
  String userDesignation = "-";
  String userDepartment = "-";
  String userMobile = "-";
  String userEmailId = "-";
  String userVisa = "";
  String userEmirateId = "";
  String userPassport = "";
  String userMedical = "";
  String userPhoto = "";
  String empId = "";
  bool isVisibleProfile = true;
  bool isVisibleDoc = false;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      final String token = prefs.getString('token').toString();
      empId = prefs.getString('username').toString();
      print(token);
      Profile(empId,token);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double halfScreenHeight = screenHeight / 6;
    double ScreenHeight6 = screenHeight / 8;
    double ScreenHeight4 = screenHeight / 3.5;

    return Scaffold(
      body: isLoading?
        progressBar(context) : SingleChildScrollView(
        child: Stack(
            children: [
              Container(
        width: double.infinity,
      height: halfScreenHeight,
      child:  ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0)),
          child: Container(
            color: ColorConstants.kPrimaryColor,
            child: Row(
              children: [
                Container(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dashboard(),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                    child: new Text("PROFILE",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                ),
              ],
            ),
          ),
      ),
        ),
              Container(
                margin: EdgeInsets.fromLTRB(20.0, ScreenHeight4, 20.0, 20.0),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0,10.0,20.0,0.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: new Text(userName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0,5.0,20.0,0.0),
                      child: new Text(userDesignation,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 70,
                      padding: const EdgeInsets.fromLTRB(10.0,20.0,10.0,0.0),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                          child: InkWell(onTap: (){
                            changeImage("profile");
                        },
                          child: Image(
                              image: AssetImage(imageUser)),
                              )),
                              Container(
                                height: 20,
                                width: 2, // Adjust the thickness of the line
                                color: Colors.grey, // Color of the vertical line
                              ),
                              Expanded(
                                child: InkWell(onTap: (){
                                  changeImage("doc");
                                },
                                child: Image(
                                    image: AssetImage(
                                        imageDoc)),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isVisibleProfile,
                      child: Container(
                        child: straightLine()
                    ),
                    ),
                    Visibility(
                      visible: isVisibleDoc,
                      child: Container(
                          child: viewDocument()
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(20.0, ScreenHeight6, 20.0, 20.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                      child: userPhoto.isNotEmpty
                          ? CircleAvatar(
                        radius: 60,
                        backgroundImage: MemoryImage(base64.decode(userPhoto.replaceAll(RegExp(r'\s+'), ''))),
                      )
                          : CircleAvatar(
                        radius: 60,
                        backgroundColor: ColorConstants.kPrimaryColor,
                        backgroundImage: AssetImage('assets/image/icon_profile1.png'),
                      )
                  ),
                ),
              )
            ],
        )
      ),
    );
  }

  Profile(String empId,String token) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': token
    };
    var data = json.encode({
      "_empId": empId
    });
    var dio = Dio();
    var response = await dio.request(
      'https://iye-live.operations.dynamics.com/api/services/AHSMobileServices/AHSMobileService/getProfile',
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
      viewprofile data = viewprofile.fromJson(response.data);
      addUserData(data);
      print(data.visa);
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.statusMessage);
    }
  }

  void addUserData(viewprofile data) {
    setState(() {
      userName = data.Name;
      userDesignation = data.designation;
      userEmailId = data.emailid;
      userDepartment = data.department;
      userMobile = data.mobilenumber;
      userVisa = data.visa;
      userEmirateId = data.emiratedid;
      userPassport = data.passport;
      userMedical = data.medical;
     // userPhoto = data.photo;
    });
  }

  _launchURL(String mapurl) async {
    await launchUrl(Uri.parse(mapurl));
  }

  Widget progressBar(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
          color: ColorConstants.kPrimaryColor,
          strokeWidth: 3,
        ));
  }

  Widget straightLine(){
    return Container(
      padding: EdgeInsets.fromLTRB(10.0,20.0,10.0,0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          InkWell(
              child: TimelineTile(
                alignment: TimelineAlign.start,
                lineXY: 0.7, // Adjust the position of the line if needed
                afterLineStyle: const LineStyle(
                  color: ColorConstants.kPrimaryColor, // Change the line color here
                  thickness: 1, // Adjust the line thickness
                ),
                isFirst: true,
                indicatorStyle: IndicatorStyle(
                  width: 22,
                  color: ColorConstants.kPrimaryColor,
                ),
                endChild: Container(
                  margin: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userDepartment,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1), // Add some space between the text widgets
                      Text(
                        "Department",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 1.0),
                ),
              )
          ),
          InkWell(
            child: TimelineTile(
              alignment: TimelineAlign.start,
              lineXY: 0.7,
              beforeLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              afterLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              indicatorStyle: IndicatorStyle(
                width: 22,
                color: ColorConstants.kPrimaryColor,
              ),
              endChild: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      empId,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1), // Add some space between the text widgets
                    Text(
                      "Employee Id",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 1.0),
              ),
            ),
          ),
          InkWell(
            child: TimelineTile(
              alignment: TimelineAlign.start,
              lineXY: 0.7,
              beforeLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              afterLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              indicatorStyle: IndicatorStyle(
                width: 22,
                color: ColorConstants.kPrimaryColor,
              ),
              endChild: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userMobile,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1), // Add some space between the text widgets
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 1.0),
              ),
            ),
          ),
          InkWell(
            child: TimelineTile(
              alignment: TimelineAlign.start,
              lineXY: 0.7,
              beforeLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              afterLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              isLast: true,
              indicatorStyle: IndicatorStyle(
                width: 22,
                color: ColorConstants.kPrimaryColor,
              ),
              endChild: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmailId,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1), // Add some space between the text widgets
                    Text(
                      "Email Id",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget viewDocument(){
    return Container(
      padding: EdgeInsets.fromLTRB(10.0,5.0,10.0,0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
              onTap: () => {
                if(userEmirateId.isNotEmpty){
                 _launchURL(userEmirateId)
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No File',
                        style: TextStyle(color: Colors.black),),
                        backgroundColor: ColorConstants.kPrimaryColor,)
                  )
                }
              },
              child: TimelineTile(
                alignment: TimelineAlign.start,
                lineXY: 0.7, // Adjust the position of the line if needed
                afterLineStyle: const LineStyle(
                  color: ColorConstants.kPrimaryColor, // Change the line color here
                  thickness: 1, // Adjust the line thickness
                ),
                isFirst: true,
                indicatorStyle: IndicatorStyle(
                  width: 22,
                  color: ColorConstants.kPrimaryColor,
                ),
                endChild: Container(
                  margin: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.all(5),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Padding(
                       padding: EdgeInsets.fromLTRB(10.0,5.0,0.0,10.0),
                    child: Text(
                        "EmiratesId.pdf",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ),
                      SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0,5.0,0.0,10.0),
                    child : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "VIEW",
                          style: TextStyle(
                            color: ColorConstants.kPrimaryColor,
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        /*Text(
                          "DOWNLOAD",
                          style: TextStyle(
                            color: ColorConstants.kPrimaryColor,
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),*/
                      ]
                    )
                  )
                    ],
                  ),
                ),
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 1.0),
                )
              )
          ),
          InkWell(
            onTap: () => {
              if(userMedical.isNotEmpty){
                _launchURL(userMedical)
              }else{
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No File',
                      style: TextStyle(color: Colors.black),),
                      backgroundColor: ColorConstants.kPrimaryColor,)
                )
              }
            },
            child: TimelineTile(
              alignment: TimelineAlign.start,
              lineXY: 0.7,
              beforeLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              afterLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              indicatorStyle: IndicatorStyle(
                width: 22,
                color: ColorConstants.kPrimaryColor,
              ),
              endChild: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0,5.0,0.0,10.0),
                        child: Text(
                          "Insurance.pdf",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Padding(
                          padding: EdgeInsets.fromLTRB(10.0,5.0,0.0,10.0),
                          child : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "VIEW",
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                /*Text(
                                  "DOWNLOAD",
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),*/
                              ]
                          )
                      )
                    ],
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 1.0),
              ),
            ),
          ),
          InkWell(
            onTap: () => {
              if(userPassport.isNotEmpty){
                _launchURL(userPassport)
              }else{
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No File',
                      style: TextStyle(color: Colors.black),),
                      backgroundColor: ColorConstants.kPrimaryColor,)
                )
              }
            },
            child: TimelineTile(
              alignment: TimelineAlign.start,
              lineXY: 0.7,
              beforeLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              afterLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              indicatorStyle: IndicatorStyle(
                width: 22,
                color: ColorConstants.kPrimaryColor,
              ),
              endChild: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0,5.0,0.0,10.0),
                        child: Text(
                          "Passport.pdf",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Padding(
                          padding: EdgeInsets.fromLTRB(10.0,5.0,0.0,10.0),
                          child : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "VIEW",
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                /*Text(
                                  "DOWNLOAD",
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),*/
                              ]
                          )
                      )
                    ],
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 1.0),
              ),
            ),
          ),
          InkWell(
            onTap: () => {
              if(userVisa.isNotEmpty){
                _launchURL(userVisa)
              }else{
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No File',
                      style: TextStyle(color: Colors.black),),
                      backgroundColor: ColorConstants.kPrimaryColor,)
                )
              }
            },
            child: TimelineTile(
              alignment: TimelineAlign.start,
              lineXY: 0.7,
              beforeLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              afterLineStyle: const LineStyle(
                color: ColorConstants.kPrimaryColor, // Change the line color here
                thickness: 1, // Adjust the line thickness
              ),
              isLast: true,
              indicatorStyle: IndicatorStyle(
                width: 22,
                color: ColorConstants.kPrimaryColor,
              ),
              endChild: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0,5.0,0.0,10.0),
                        child: Text(
                          "Visa.pdf",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Padding(
                          padding: EdgeInsets.fromLTRB(10.0,5.0,0.0,10.0),
                          child : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "VIEW",
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                               /* Text(
                                  "DOWNLOAD",
                                  style: TextStyle(
                                    color: ColorConstants.kPrimaryColor,
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),*/
                              ]
                          )
                      )
                    ],
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeImage(String value) {
    setState(() {
      if(value == "profile"){
        isVisibleProfile = true;
        isVisibleDoc = false;
        imageUser = 'assets/image/icon_user_gold.png';
        imageDoc = "assets/image/icon_doc_gold.png";
      }else if(value == "doc"){
        isVisibleProfile = false;
        isVisibleDoc = true;
        imageUser = 'assets/image/icon_user_grey.png';
        imageDoc = "assets/image/icon_doc_grey.png";
      }
    });
  }
}