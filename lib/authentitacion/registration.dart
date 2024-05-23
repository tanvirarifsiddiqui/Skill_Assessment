import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:retina_soft_skill_test/Pages/home_screen.dart';
import 'dart:convert';

import 'package:retina_soft_skill_test/authentitacion/login.dart';
import 'package:retina_soft_skill_test/constants/app_constants.dart';

import '../Services/api.dart';
import '../Global/global_variables.dart';
import '../constants/input_decoration.dart';
import '../models/user_model.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isRegistered = false;
  String _identifierId = '';
  List<dynamic> _businessTypes = [];
  int? _selectedBusinessTypeId;

  @override
  void initState() {
    super.initState();
    _fetchBusinessTypes();
  }

  Future<void> _fetchBusinessTypes() async {
    final response = await http.get(Uri.parse('${API.baseURL}/get-business-types'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _businessTypes = responseData['business_types'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load business types'),
      ));
    }
  }

  Future<void> _sendOtp() async {
    final response = await http.post(
      Uri.parse('${API.baseURL}/sign-up/store'),
      body: {
        'email': _emailController.text,
        'phone': _phoneController.text,
        'name': _nameController.text,
        'business_name': _businessNameController.text,
        'business_type_id': _selectedBusinessTypeId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(response.body);
      if (responseData['status'] == 200) {
        setState(() {
          _isOtpSent = true;
          _identifierId = responseData['identifier_id'].toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['description']),
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

  Future<void> _verifyOtp() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${API.baseURL}/sign-up/verify-otp-code'),
    );
    request.fields['identifier_id'] = _identifierId;
    request.fields['otp_code'] = _otpController.text;

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      if (responseData['status'] == 200) {
        print(responseData);
        String token = responseData['response_user']['api_token'];
        int branchId = responseData['response_user']['branch_id'];
        print(token);
        print(branchId);
        setState(() {
          user = User.fromJson(responseData['response_user']);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['description']),
        ));
        Get.to(HomeScreen());
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

  Future<void> _resendOtp() async {
    final response = await http.post(
      Uri.parse('${API.baseURL}/sign-up/send-otp-code'),
      body: {
        'email': _emailController.text,
        'phone': _phoneController.text,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 200) {
        print(responseData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['description']),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['description']),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConstants.appBarPrimary(title: "Registration"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRegistered) ...[
                TextField(
                  controller: _emailController,
                  decoration: CustomInputDecoration.buildInputDecoration('Email'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: CustomInputDecoration.buildInputDecoration('Phone'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: CustomInputDecoration.buildInputDecoration('Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _businessNameController,
                  decoration: CustomInputDecoration.buildInputDecoration('Business Name'),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedBusinessTypeId,
                  decoration: CustomInputDecoration.buildInputDecoration('Business Type'),
                  items: _businessTypes.map<DropdownMenuItem<int>>((type) {
                    return DropdownMenuItem<int>(
                      value: type['id'],
                      child: Text(type['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBusinessTypeId = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendOtp,
                  child: Text('Send OTP'),
                ),
                if (_isOtpSent) ...[
                  SizedBox(height: 10),
                  TextField(
                    controller: _otpController,
                    decoration: CustomInputDecoration.buildInputDecoration('OTP Code'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _verifyOtp,
                    child: Text('Verify OTP'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resendOtp,
                    child: Text('Resend OTP'),
                  ),
                ],
              ] else ...[
                Text('Registration successful!'),
              ],
              SizedBox(height: 50),
              TextButton(
                onPressed: () {
                  Get.to(() => LoginPage());
                },
                child: Text("Login Screen"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
