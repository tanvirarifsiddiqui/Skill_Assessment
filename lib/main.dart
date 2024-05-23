import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retina_soft_skill_test/authentitacion/registration.dart';
import 'package:retina_soft_skill_test/constants/app_constants.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter OTP Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppConstants.primaryThemeColor,
      ),
      home: RegistrationPage(),
    );
  }
}

