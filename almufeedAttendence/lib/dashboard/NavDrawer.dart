import 'package:almufeedattendence/Colours.dart';
import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: ColorConstants.kPrimaryColor),
            accountName: Text(
              "Pinkesh Darji",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              "pinkesh.earth@gmail.com",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            currentAccountPicture: FlutterLogo(),
          ),
          ListTile(
            leading: Icon(
              Icons.login_outlined,
            ),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
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
            applicationName: 'AHS Properties',
            applicationVersion: '1.0.0',
            applicationLegalese: 'Time Attendence',
            aboutBoxChildren: [
              ///Content goes here...
            ],
          ),
        ],
      ),
    );
  }
}