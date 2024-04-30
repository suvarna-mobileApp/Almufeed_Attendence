import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:ui';
import 'package:almufeedattendence/Constants.dart';
import 'package:almufeedattendence/dashboard/NewDashboard.dart';
import 'package:almufeedattendence/login/signIn.dart';
import 'package:almufeedattendence/model/location/SendLocationResponseModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Colours.dart';
import '../model/login/AccessToken.dart';
import '../model/profile/viewprofile.dart';
import '../myattendence/MyAttendence.dart';
import '../profile/ViewProfile.dart';

/*final GlobalKey<_DashboardExampleState> dashboardKey = GlobalKey<_DashboardExampleState>();

onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });
      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Al Mufeed Group - HR",
          content: "Running in background",
        );
      }

      service.invoke(
        'update', {
          "current_date": DateTime.now().toIso8601String(),
        },
      );

      //print('not matching...' + Constants.sms);

      dashboardKey.currentState?.getCurrentLocation();

    });
  }*/

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardExampleState();
}

class _DashboardExampleState extends State<Dashboard> with TickerProviderStateMixin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String currentDate = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String currentTime = DateFormat.jm().format(DateTime.now());
  late GoogleMapController mapController;
  late Marker currentLocaMarker;
  late LocationData currentLocation;
  Location location = Location();
  late StreamSubscription<LocationData> _locationSubscription;
  final Set<Marker> markers = new Set();
  Set<Circle> circles = new Set();
  String checkedInText = "Punch-In";
  String checkedInTextDate = "";
  bool showText = false;
  bool isLoading = false;
  bool showNotification = false;
  bool punchflag = false;
  String empId = "";
  String userName = "";
  String userMobile = "-";
  String buildName = "";
  String  token = "";
  String userPhoto = "";
  late SharedPreferences prefs;
  List<String> latitude = List<String>.of([]);
  List<String> longitude = List<String>.of([]);
  List<String> buildingName = List<String>.of([]);

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    var initializationSettingsAndroid = AndroidInitializationSettings('logo');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);
   // initializeApp();
    getToken();
    getCurrentLocation();
  }

/*  initializeApp() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(

        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    service.startService();
  }

  Future<bool> onIosBackground(ServiceInstance serviceInstance) async {
    return true;
  }*/

  void getToken() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      latitude = prefs.getStringList('locationLat')!;
      longitude = prefs.getStringList('locationLong')!;
      buildingName = prefs.getStringList('locationName')!;
      empId = prefs.getString('username').toString();
      token = prefs.getString('token').toString();
      punchflag = prefs.getBool('punchflag')!;

      if(punchflag == true){
        checkedInText = "Punch-Out";
        showText = true;
      }else{
        checkedInText = "Punch-In";
      }
      Profile(empId,token);
    });
  }

  Profile(String empId,String token) async {
    try{
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
        userName = data.Name;
        userMobile = data.mobilenumber;
        userPhoto = data.photo;
      } else {
        setState(() {
          isLoading = false;
        });
        print(response.statusMessage);
      }
    } on DioError catch(e) {
      if (e.response!.statusCode == 401) {
        Autorization();
      }
    }
  }

  Autorization() async {
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
        Profile(empId, "Bearer " + data.accessToken);
      });
    } else {
      print(response.statusMessage);
    }
  }

  addCurrentLocMarker(LocationData locationData){
    /// Current Location marker, that will also be updating
      currentLocaMarker = Marker(
      markerId: MarkerId('currentLocation'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: LatLng(locationData.latitude!, locationData.longitude!),
      infoWindow: InfoWindow(title: 'Current Location', snippet: 'my location'),
      onTap: () {
        print('current location tapped');
      },
    );
  }

  void getCurrentLocation() async{
    if (!await Permission.location.request().isGranted) {
      //return false;
    }

    location = Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // return false;
      }
    }

    final LocationData _locationData = await location.getLocation();

    if(location.isBackgroundModeEnabled() == false){
      location.enableBackgroundMode(enable: true);
    }

    location.getLocation().then((value){
      currentLocation = value;
      addCurrentLocMarker(currentLocation);
    });

    _locationSubscription = location.onLocationChanged.listen((newLoc) {
      setState(() {
        currentLocation = newLoc;
        addCurrentLocMarker(newLoc);
      });
    });

      await location.changeSettings(accuracy: LocationAccuracy.high, interval: 5000, distanceFilter: 0);
      location.onLocationChanged.listen((newLoc) {

        double distanceBetween = 0.0;
        for (int i = 0; i < latitude.length; i++) {
        double latString = double.parse(latitude[i]);
        double longString = double.parse(longitude[i]);

        String inString = latString.toStringAsFixed(3);
        String newString = newLoc.latitude!.toStringAsFixed(3);

        distanceBetween = haversineDistance(
            LatLng(latString, longString), LatLng(
            newLoc.latitude!, newLoc.longitude!));

        if (distanceBetween < 200) {
          if(punchflag == false){
            if(inString == newString){
              buildName = buildingName[i];
              if(checkedInText == "Punch-In"){
                prefs.setBool('punchflag', true);
                sendLocationToServer(empId, buildName, "Y",buildName);
                scheduleNotification("Al Mufeed - HR", "You are at office - Punch In");
                break;
              }
            }
          }
        } else {
            /*if (checkedInText == "Punch-Out") {
              if(punchflag == true){
                if(inString == newString){
                  prefs.setBool('punchflag', false);
                  sendLocationToServer(empId, buildName, "",buildName);
                  scheduleNotification("Al Mufeed - HR", "You are out of office - Punch out");
                }
              }
            }*/
          }
      }
      });
  }

  Future<void> scheduleNotification(String title, String subtitle) async {
    print("scheduling one with $title and $subtitle");
    var rng = new Random();
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'your channel id', 'your channel name',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0, title, subtitle, platformChannelSpecifics,
          payload: 'item x');
  }

  dynamic haversineDistance(LatLng player1, LatLng player2) {
    double lat1 = player1.latitude;
    double lon1 = player1.longitude;
    double lat2 = player2.latitude;
    double lon2 = player2.longitude;

    var R = 6371e3; // metres
    // var R = 1000;
    var phi1 = (lat1 * pi) / 180; // φ, λ in radians
    var phi2 = (lat2 * pi) / 180;
    var deltaPhi = ((lat2 - lat1) * pi) / 180;
    var deltaLambda = ((lon2 - lon1) * pi) / 180;

    var a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) *
            sin(deltaLambda / 2) *
            sin(deltaLambda / 2);

    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // in metres
    return d;
  }

  void changeName(String buttonName, String textName){
    setState(() {
      currentDate = DateFormat.yMMMMd('en_US').format(DateTime.now());
      currentTime = DateFormat.jm().format(DateTime.now());
      buttonName = checkedInText;
      textName = checkedInTextDate;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _removeValue() async {
    await prefs.remove('username');
    await prefs.remove('firstLogin');
    await prefs.remove("token");
    await prefs.remove("punchflag");
    setState(() {
      empId = '';
      token = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double halfScreenHeight = screenHeight / 4;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
             UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: ColorConstants.kPrimaryColor),
              accountName: Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                userMobile,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: SizedBox(
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
            ListTile(
              leading: Icon(
                Icons.login_outlined,
              ),
              title: const Text('Logout'),
              onTap: () {
                _removeValue();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => signIn()
                  ),
                );
              },
            ),
            AboutListTile( // <-- SEE HERE
              icon: Icon(
                Icons.info,
              ),
              child: Text('About app'),
              applicationIcon: Icon(
                Icons.local_play,
              ),
              applicationName: 'Al Mufeed Group',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Time Attendence',
              aboutBoxChildren: [
                ///Content goes here...
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: ColorConstants.kPrimaryColor),
        /*leading: IconButton(
          icon: Icon(Icons.menu_rounded),
          color: ColorConstants.kPrimaryColor,
          onPressed: () {
          },
        ),*/
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: ColorConstants.kPrimaryColor,
            fontFamily: 'Montserrat',// Text color
            fontSize: 18, // Font size
            fontWeight: FontWeight.bold, // Font weight
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active),
            color: ColorConstants.kPrimaryColor,
            onPressed: () {

            },
          ),
        ],
        centerTitle: true, // Center the title horizontally
        backgroundColor: Colors.white, // AppBar background color
      ),
      body: isLoading?
      progressBar(context) :SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
          margin: EdgeInsets.fromLTRB(10.0, 20, 10.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                //margin: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      child: Text(userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                    ),
                    Container(
                      child: Text(currentDate + " , " + currentTime,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10.0,10.0,10.0,10.0),
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 4, backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {

                    for (int i = 0; i < latitude.length; i++) {
                      var latString1 = double.parse(latitude[i]);

                      String inString = latString1.toStringAsFixed(3);
                      String newString = currentLocation.latitude!.toStringAsFixed(3);
                      print('punchin time...' + inString.toString() +  " lon " + newString.toString() + " buidlingname " + buildingName[i]);
                      if(inString != newString){
                        buildName = buildingName[i];
                        if(checkedInText == "Punch-In"){
                          isLoading = true;
                          prefs.setBool('punchflag', true);
                          sendLocationToServer(empId, buildName, "Y",buildName);
                          scheduleNotification("Al Mufeed - HR", "You are at office - Punch In");
                          break;
                        }
                      }
                    }

                    if (checkedInText == "Punch-Out") {
                      if(punchflag == true){
                        prefs.setBool('punchflag', false);
                        sendLocationToServer(empId, buildName, "",buildName);
                        scheduleNotification("Al Mufeed - HR", "You are out of office - Punch out");
                      }
                    }
                  },
                  child: Text(
                    checkedInText,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
            if (showText)
              Align(
                alignment: Alignment.topLeft,
                child: _checkIn(context),
              ),
            Center(child:
            Column(children: [
              Row(children: [ Expanded(child: InkWell(onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewDashboard(),
                  ),
                );
              },child: Card(
                margin: EdgeInsets.all(10),
                child: ClipPath(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: ColorConstants.kPrimaryColor, width: 3),
                      ),
                    ),
                    child: Center(child: Column(
                        children: [Padding(padding: EdgeInsets.all(10),
                            child: Image(
                                image: AssetImage(
                                    'assets/image/user_location.png'))),
                          Padding(padding: EdgeInsets.all(10),
                              child: Text(
                                  'My Location',
                                  style: TextStyle(fontSize: 16)))
                        ])
                    ),
                  ),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                ),
              ))), Expanded(flex: 1, child: InkWell(onTap: (){
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => MyAttendence(),
    ),
    );
    },child: Card(
                margin: EdgeInsets.all(10),
                child: ClipPath(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: ColorConstants.kPrimaryColor, width: 3),
                      ),
                    ),
                    child: Center(child: Column(
                        children: [Padding(padding: EdgeInsets.all(10),
                            child: Image(
                                image: AssetImage(
                                    'assets/image/user_attendence48.png'))),
                          Padding(padding: EdgeInsets.all(10),
                              child: Text(
                                  'My Attendence',
                                  style: TextStyle(fontSize: 16)))
                        ])
                    ),
                  ),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                ),))),
              ]),
            ])),
            Center(child: Column(children: [
              Row(children: [ Expanded(child: InkWell(onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProfile(),
                  ),
                );
              },child: Card(
                  margin: EdgeInsets.all(10),
                child: ClipPath(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: ColorConstants.kPrimaryColor, width: 3),
                      ),
                    ),
                      child: Center(
                          child: Column(
                          children: [Padding(padding: EdgeInsets.all(10),
                              child: Image(
                                  image: AssetImage(
                                      'assets/image/user_profile48.png'))),
                            Padding(padding: EdgeInsets.all(10),
                                child: Text(
                                    'My Profile',
                                    style: TextStyle(fontSize: 16)))
                          ])
                      ),
                  ),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                ),
              ))), /*Expanded(flex: 1, child: Card(
                margin: EdgeInsets.all(10),
                child: ClipPath(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: ColorConstants.kPrimaryColor, width: 3),
                      ),
                    ),
                    child: Center(child: Column(
                        children: [Padding(padding: EdgeInsets.all(10),
                            child: Image(
                                image: AssetImage(
                                    'assets/image/user_request.png'))),
                          Padding(padding: EdgeInsets.all(10),
                              child: Text(
                                  'My Request',
                                  style: TextStyle(fontSize: 16)))
                        ])
                    ),
                  ),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                ),))*/
              ]),
            ])),
          /*  Container(
              width: double.infinity,
              height: 400,
              margin: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
              child: GoogleMap( //Map widget from google_maps_flutter package
                zoomGesturesEnabled: true, //enable Zoom in, out on map
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentLocation.latitude! , currentLocation.longitude!,),//innital position in map
                  //target: showLocation, //initial position
                  zoom: 16.0, //initial zoom level
                ),
                markers: getmarkers(),
                circles: circles,//markers to show on map
                mapType: MapType.normal, //map type
                onMapCreated: (GoogleMapController controller) { //method called when map is created
                  setState(() {
                    mapController = controller;
                  });
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
                child: _buttons(checkedInText,context)
            ),
          if (showText)
            Align(
              alignment: Alignment.bottomCenter,
              child: _checkIn(context),
            ),*/
          ],
        ),
      ),
    );
  }

  sendLocationToServer(String empId,String location,String status,String name) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token').toString();

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': token
    };
    var data = json.encode({
      "_employeeID": empId,
      "_location": location,
      "_status": status
    });
    var dio = Dio();
    var response = await dio.request(
      'https://iye-live.operations.dynamics.com/api/services/AHSMobileServices/AHSMobileService/setLocation',
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
      SendLocationResponseModel data = SendLocationResponseModel.fromJson(response.data);
      if(data.result == true){
        if(status == "Y" && checkedInText == "Punch-In"){
          showText = true;
          _checkIn(context);
          checkedInText = "Punch-Out";
          checkedInTextDate = 'Punched In ' + name + '\n' + currentDate + " " + currentTime;
          changeName(checkedInText,checkedInTextDate);
        }else if(status == "" && checkedInText == "Punch-Out"){
          showText = true;
          _checkIn(context);
          checkedInTextDate = 'Punched Out ' + name + '\n' + currentDate + " " + currentTime;
          checkedInText = "Punch-In";
          changeName(checkedInText,checkedInTextDate);
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.statusMessage);
    }
  }

  Widget _checkIn(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10.0, 20, 10.0, 20.0),
          child: new Text(checkedInTextDate,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
    );
  }

  String dateTime(BuildContext context){
    final now = new DateTime.now();
    String formatter = DateFormat.yMMMMd('en_US').format(now);
    return formatter;
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
}