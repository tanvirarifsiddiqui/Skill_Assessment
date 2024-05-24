import 'package:flutter/material.dart';

class AppConstants {
  static const Color primaryColor = Color(0xff37b34a);
  static const Color secondaryColor = Color(0xff19c734);
  static const MaterialColor primaryThemeColor = Colors.green;
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xff37b34a), Color(0xff19c734)],
    stops: [0.25, 0.75],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color primaryTextColor = Colors.white;

  static AppBar appBarPrimary({required String title}) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: primaryTextColor)),
      iconTheme: const IconThemeData(color: primaryTextColor),
      centerTitle: true,
      backgroundColor: primaryColor,
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.more_vert),
      //     onPressed: () {
      //       // Define your action here
      //     },
      //   ),
      // ],
    );
  }
}
