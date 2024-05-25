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
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: AppConstants.primaryColor),
          headlineSmall: TextStyle(color: AppConstants.primaryColor),

        ),
        primaryColor: AppConstants.primaryColor, colorScheme: ColorScheme.fromSwatch(primarySwatch: AppConstants.primaryThemeColor).copyWith(background: AppConstants.scaffoldBackgroundColor),
      ),
      home: RegistrationPage(),
    );
  }
}

