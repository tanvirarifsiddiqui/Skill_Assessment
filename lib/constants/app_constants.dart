import 'package:flutter/material.dart';

class AppConstants{
  static const Color primaryColor = Color(0xFF0C73D5);
  static const MaterialColor primaryThemeColor = Colors.blue;
  static const Color primaryTextColor = Colors.white;

  static AppBar appBarPrimary({required String title}) {
    return AppBar(
      title: Text(title,style: const TextStyle(color: primaryTextColor)),
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