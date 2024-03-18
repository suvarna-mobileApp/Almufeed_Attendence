import 'package:almufeedattendence/Colours.dart';
import 'package:almufeedattendence/dashboard/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login/signIn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: ColorConstants.kPrimaryColor
    ));
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ColorConstants.kPrimaryColor),
          useMaterial3: true,
        ),
        home: Main()
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() =>
      _MainState();
}

class _MainState extends State<Main>{
  bool isFirstLogin = false;

  @override
  void initState() {
    super.initState();
    getLoginFirst();
  }

  void getLoginFirst() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFirstLogin = prefs.getBool('firstLogin')!;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ColorConstants.kPrimaryColor),
          useMaterial3: true,
        ),
        home: isFirstLogin? Dashboard() : signIn()
    );
  }
}

