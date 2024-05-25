import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:retina_soft_skill_test/authentitacion/registration.dart';
import 'package:retina_soft_skill_test/constants/app_constants.dart';
import 'package:retina_soft_skill_test/constants/custom_button.dart';
import '../Services/api.dart';
import 'package:retina_soft_skill_test/Pages/home_screen.dart';
import 'dart:convert';

import '../Global/global_variables.dart';
import '../constants/input_decoration.dart';
import '../models/user_model.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;

  Future<void> _sendOtp() async {
    final response = await http.post(
      Uri.parse('${API.baseURL}/send-login-otp'),
      body: {'identifier': _emailController.text},
    );

    print(response.statusCode);
    print(response.body);
    print(_emailController.text);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 200) {
        setState(() {
          _isOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['description']),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.statusCode}'),
      ));
    }
  }

  Future<void> _login() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${API.baseURL}/login'),
    );
    request.fields['identifier'] = _emailController.text;
    request.fields['otp_code'] = _otpController.text;

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      if (responseData['status'] == 200) {
        print(responseData);
        String token = responseData['user']['api_token'];
        int branchId = responseData['user']['branch_id'];
        print(token);
        print(branchId);
        setState(() {
          user = User.fromJson(responseData['user']);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['description']),
        ));
        Get.offAll(HomeScreen());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.statusCode}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConstants.appBarPrimary(title: "OTP Login"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: CustomInputDecoration.buildInputDecoration('Email or Phone'),
            ),
            if (_isOtpSent)...[
              SizedBox(height: 20,),
              TextField(
                controller: _otpController,
                decoration: CustomInputDecoration.buildInputDecoration('OTP Code'),
                keyboardType: TextInputType.number,
              ),
            ],
            SizedBox(height: 20),
            CustomButton(
              height: 50,
                onPressed: _isOtpSent ? _login : _sendOtp,
                text: _isOtpSent ? 'Login' : 'Send OTP'),
            SizedBox(height: 20,),
            TextButton(
              onPressed: () {
                Get.to(() => RegistrationPage());
              },
              child: const Text("Register Here",style: TextStyle(fontSize: 18),),
            ),
          ],
        ),
      ),
    );
  }
}
