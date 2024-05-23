import 'package:flutter/material.dart';
import 'package:retina_soft_skill_test/constants/app_constants.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConstants.appBarPrimary(title: "Profile"),
    );
  }
}