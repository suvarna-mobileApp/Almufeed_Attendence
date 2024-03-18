import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import '../Colours.dart';
import '../profile/ViewProfile.dart';
import 'Dashboard.dart';
import 'NavDrawer.dart';

class NewDashboard extends StatelessWidget {
  const NewDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NewDashboardExample(),
    );
  }
}

class NewDashboardExample extends StatefulWidget {
  const NewDashboardExample({super.key});

  @override
  State<NewDashboardExample> createState() =>
      _DashboardExampleState();
}

class _DashboardExampleState extends State<NewDashboardExample> with TickerProviderStateMixin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String currentDate = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String currentTime = DateFormat.jm().format(DateTime.now());
  late GoogleMapController mapController;
  late Marker currentLocaMarker;
  late LatLng showLocation = const LatLng(25.09554209900229, 55.17285329480057);
  double damaclat = 25.09554209900229;
  double damaclong = 55.17285329480057;
  double salelat = 25.2041855;
  double salelonf = 55.2628803;
  Location location = Location();
  late StreamSubscription<LocationData> _locationSubscription;
  final Set<Marker> markers = new Set();
  Set<Circle> circlesDamac = new Set();
  Set<Circle> circlesSaleCenter = new Set();
  String checkedInText = "Punch-In";
  String checkedInTextDate = "Punch-In";
  bool showText = false;

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);
    getCurrentLocation();
    getCircleDamac();
    getCircleSaleCenter();
    getmarkers();
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
    Location location = Location();
    LocationData currentLocation = await location.getLocation();
    location.getLocation().then((value){
      damaclong = currentLocation.longitude!;
      damaclat = currentLocation.latitude!;
      currentLocation = value;
      /// add Markers for current location
      addCurrentLocMarker(currentLocation!);
    });

    _locationSubscription = location.onLocationChanged.listen((newLoc) {
      setState(() {
        /// update the currentLocation with new location value
        currentLocation = newLoc;
        // We have to also update the markers by passing the new location value
        addCurrentLocMarker(newLoc);
      });
    });

    location.onLocationChanged.listen((newLoc) {

      var distanceBetween = haversineDistance(
          LatLng(damaclat, damaclong), LatLng(
          newLoc.latitude!, newLoc.longitude!));
      print('distance between... ${distanceBetween}');


      if (distanceBetween < 200) {
        print('user reached to the destination...');

       /* scheduleNotification(
            "Georegion added", "Your geofence has been added! - damac");
*/
        /// I simply show a snackBar message here you can implement your custom logic here.
        /*ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You reached to the location',
                style: TextStyle(color: Colors.white),),
                backgroundColor: Colors.redAccent,)
          );*/
      }else{
        /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You reached to the location',
              style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.redAccent,)
        );*/

       /* scheduleNotification(
            "Georegion added", "You are outside radius");*/
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
        rng.nextInt(100000), title, subtitle, platformChannelSpecifics,
        payload: 'item x');
    /* Future.delayed(Duration(seconds: 2)).then((result) async {
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
          rng.nextInt(100000), title, subtitle, platformChannelSpecifics,
          payload: 'item x');
    });*/
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

  Set<Marker> getmarkers() {
    setState(() {
      markers.add(Marker(
        markerId: MarkerId(""),
        position: showLocation,
        infoWindow: InfoWindow(
          title: 'Corporate Office',
          snippet: 'Damac executive heights',
        ),
        icon: BitmapDescriptor.defaultMarker,
        onTap: () => "Damac executive heights",
      ));
    });

    return markers;
  }

  Set<Circle> getCircleDamac() {
    setState(() {
      circlesDamac = Set.from([
        Circle(
          circleId: CircleId('geo_fence_1'),
          center: LatLng(damaclat, damaclong),
          radius: 200,
          strokeWidth: 2,
          strokeColor: ColorConstants.kPrimaryColor,
          fillColor: ColorConstants.kPrimaryColor.withOpacity(0.15),
        ),
      ]);
    });

    return circlesDamac;
  }

  Set<Circle> getCircleSaleCenter() {
    setState(() {
      circlesSaleCenter = Set.from([
        Circle(
          circleId: CircleId('geo_fence_1'),
          center: LatLng(salelat, salelonf),
          radius: 200,
          strokeWidth: 2,
          strokeColor: ColorConstants.kPrimaryColor,
          fillColor: ColorConstants.kPrimaryColor.withOpacity(0.15),
        ),
      ]);
    });

    return circlesSaleCenter;
  }

  @override
  void dispose() {
    super.dispose();
  }

 /* @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double halfScreenHeight = screenHeight / 4;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
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
           *//* Align(
                alignment: Alignment.bottomCenter,
                child: _buttons(checkedInText,context)
            ),
            if (showText)
              Align(
                alignment: Alignment.bottomCenter,
                child: _checkIn(context),
              ),*//*
          ],
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double halfScreenHeight = screenHeight / 4;

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
          'My Location',
          style: TextStyle(
            color: ColorConstants.kPrimaryColor,
            fontFamily: 'Montserrat',// Text color
            fontSize: 18, // Font size
            fontWeight: FontWeight.bold, // Font weight
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: GoogleMap( //Map widget from google_maps_flutter package
                zoomGesturesEnabled: true, //enable Zoom in, out on map
                initialCameraPosition: CameraPosition(
                  target: LatLng(damaclat , damaclong),//innital position in map
                  zoom: 16.0, //initial zoom level
                ),
                //markers: getmarkers(),
                markers: LatLng(damaclat , damaclong) != null
      ? {
      Marker(
      markerId: MarkerId("current_location"),
      position: LatLng(damaclat , damaclong),
      infoWindow: InfoWindow(
      title: "Current Location",
      ),
      ),
      }
              : {},
                //circles: circlesDamac,
     circles: {
          Circle(
            circleId: CircleId("circle_current_location"),
            center: LatLng(damaclat, damaclong),
            radius: 200,
            strokeWidth: 2,
            strokeColor: ColorConstants.kPrimaryColor,
            fillColor: ColorConstants.kPrimaryColor.withOpacity(0.15),
          ),
          Circle(
            circleId: CircleId("circle_second_location"),
            center: LatLng(salelat, salelonf),
            radius: 200,
            strokeWidth: 2,
            strokeColor: ColorConstants.kPrimaryColor,
            fillColor: ColorConstants.kPrimaryColor.withOpacity(0.15),
          ),
        },

                mapType: MapType.normal, //map type
                onMapCreated: (GoogleMapController controller) { //method called when map is created
                  setState(() {
                    mapController = controller;
                  });
                },
              ),
    );
  }

  Widget _buttons(name, BuildContext context) {
    return Center(
        child: ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ButtonTheme(
                minWidth: 200,
                child: ElevatedButton(
                  child: new Text(name,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                    if(checkedInText == "Punch-In"){
                      showText = true;
                      _checkIn(context);
                      checkedInText = "Punch-Out";
                      checkedInTextDate = 'Punched In Damac Executive heights \n' + currentDate + " " + currentTime;
                      changeName(checkedInText,checkedInTextDate);
                    }else if(checkedInText == "Punch-Out"){
                      showText = true;
                      _checkIn(context);
                      checkedInTextDate = 'Punched Out Damac Executive heights \n' + currentDate + " " + currentTime;
                      checkedInText = "Punch-In";
                      changeName(checkedInText,checkedInTextDate);
                    }
                  },
                )
            ),
          ],
        )
    );
  }

  Widget _checkIn(BuildContext context) {
    return Center(
      child: Container(
        child: new Text(checkedInTextDate,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
}