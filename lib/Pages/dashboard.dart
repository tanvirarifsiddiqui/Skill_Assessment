import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:retina_soft_skill_test/Global/global_variables.dart';
import 'package:retina_soft_skill_test/Pages/transaction_page.dart';
import 'package:retina_soft_skill_test/constants/app_constants.dart';
import 'package:retina_soft_skill_test/models/customer_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';

import '../constants/custom_button.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final int type = 0; // 0 for Customer, 1 for Supplier

  String apiToken = user!.apiToken;
  int branchID = user!.branchId;
  bool isCustomerFetched = false;

  List<CustomerDash> _customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final response = await http.get(
      Uri.parse(
          'https://skill-test.retinasoft.com.bd/api/v1/admin/${branchID}/$type/customers'),
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> customersData =
          responseData['customers']['customers'];

      setState(() {
        _customers =
            customersData.map((data) => CustomerDash.fromJson(data)).toList();
        isCustomerFetched = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch customers'),
        ),
      );
    }
  }

  _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _areaController.clear();
    _postCodeController.clear();
    _cityController.clear();
    _stateController.clear();
  }

  Future<void> _createCustomer() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://skill-test.retinasoft.com.bd/api/v1/admin/$branchID/customer/create'),
    );
    request.fields['name'] = _nameController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['email'] = _emailController.text;
    request.fields['type'] = type.toString();
    request.fields['address'] = _addressController.text;
    request.fields['area'] = _areaController.text;
    request.fields['post_code'] = _postCodeController.text;
    request.fields['city'] = _cityController.text;
    request.fields['state'] = _stateController.text;
    request.headers['Authorization'] = 'Bearer $apiToken';

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      if (responseData['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['description']),
        ));
        _clearForm();
        _fetchCustomers(); // Refresh the customer list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create customer'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.statusCode}'),
      ));
    }
  }

  Future<void> _updateCustomer(int customerId) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://skill-test.retinasoft.com.bd/api/v1/admin/$branchID/customer/$customerId/update'),
    );
    request.fields['name'] = _nameController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['email'] = _emailController.text;
    request.fields['type'] = type.toString();
    request.fields['address'] = _addressController.text;
    request.fields['area'] = _areaController.text;
    request.fields['post_code'] = _postCodeController.text;
    request.fields['city'] = _cityController.text;
    request.fields['state'] = _stateController.text;

    request.headers['Authorization'] = 'Bearer $apiToken';

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      if (responseData['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['description']),
        ));
        _clearForm();
        _fetchCustomers(); // Refresh the customer list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update customer'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.statusCode}'),
      ));
    }
  }

  Future<void> _deleteCustomer(int customerId) async {
    final response = await http.delete(
      Uri.parse(
          'https://skill-test.retinasoft.com.bd/api/v1/admin/$branchID/customer/$customerId/delete'),
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['description']),
        ));
        _fetchCustomers(); // Refresh the customer list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete customer'),
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
      appBar: AppConstants.appBarPrimary(title: "Dashboard"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       showDialog(
          //         context: context,
          //         builder: (BuildContext context) {
          //           return AlertDialog(
          //             title: const Text('Add Customer'),
          //             content: SingleChildScrollView(
          //               child: Column(
          //                 children: [
          //                   TextField(
          //                     controller: _nameController,
          //                     decoration: InputDecoration(labelText: 'Name'),
          //                   ),
          //                   TextField(
          //                     controller: _phoneController,
          //                     decoration: InputDecoration(labelText: 'Phone'),
          //                   ),
          //                   TextField(
          //                     controller: _emailController,
          //                     decoration: InputDecoration(labelText: 'Email'),
          //                   ),
          //                   TextField(
          //                     controller: _addressController,
          //                     decoration: InputDecoration(labelText: 'Address'),
          //                   ),
          //                   TextField(
          //                     controller: _areaController,
          //                     decoration: InputDecoration(labelText: 'Area'),
          //                   ),
          //                   TextField(
          //                     controller: _postCodeController,
          //                     decoration: InputDecoration(labelText: 'Post Code'),
          //                   ),
          //                   TextField(
          //                     controller: _cityController,
          //                     decoration: InputDecoration(labelText: 'City'),
          //                   ),
          //                   TextField(
          //                     controller: _stateController,
          //                     decoration: InputDecoration(labelText: 'State'),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             actions: <Widget>[
          //               TextButton(
          //                 child: Text('Cancel'),
          //                 onPressed: () {
          //                   Navigator.of(context).pop();
          //                 },
          //               ),
          //               TextButton(
          //                 child: Text('Create'),
          //                 onPressed: () {
          //                   _createCustomer();
          //                   Navigator.of(context).pop();
          //                 },
          //               ),
          //             ],
          //           );
          //         },
          //       );
          //     },
          //     child: Text('Create Customer'),
          //   ),
          // ),
          Container(
            color: AppConstants.primaryColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer',
                    style: TextStyle(
                      color: AppConstants.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Balance',
                    style: TextStyle(
                      color: AppConstants.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          isCustomerFetched
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      final customer = _customers[index];
                      return Slidable(
                        key: ValueKey(customer.id),
                        startActionPane: ActionPane(
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _nameController.text = customer.name;
                                _phoneController.text = customer.phone;
                                _emailController.text = '';
                                _addressController.text = '';
                                _areaController.text = '';
                                _postCodeController.text = '';
                                _cityController.text = '';
                                _stateController.text = '';

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Update Customer'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          children: <Widget>[
                                            TextField(
                                              controller: _nameController,
                                              decoration: InputDecoration(
                                                  labelText: 'Name'),
                                            ),
                                            TextField(
                                              controller: _phoneController,
                                              decoration: InputDecoration(
                                                  labelText: 'Phone'),
                                            ),
                                            TextField(
                                              controller: _emailController,
                                              decoration: InputDecoration(
                                                  labelText: 'Email'),
                                            ),
                                            TextField(
                                              controller: _addressController,
                                              decoration: InputDecoration(
                                                  labelText: 'Address'),
                                            ),
                                            TextField(
                                              controller: _areaController,
                                              decoration: InputDecoration(
                                                  labelText: 'Area'),
                                            ),
                                            TextField(
                                              controller: _postCodeController,
                                              decoration: InputDecoration(
                                                  labelText: 'Post Code'),
                                            ),
                                            TextField(
                                              controller: _cityController,
                                              decoration: InputDecoration(
                                                  labelText: 'City'),
                                            ),
                                            TextField(
                                              controller: _stateController,
                                              decoration: InputDecoration(
                                                  labelText: 'State'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Update'),
                                          onPressed: () {
                                            _updateCustomer(customer.id);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              backgroundColor: Colors
                                  .blue, // Change this to your desired background color
                              foregroundColor:
                                  Colors.white, // Icon and text color
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _deleteCustomer(customer.id);
                              },
                              backgroundColor: Colors
                                  .red, // Change this to your desired background color
                              foregroundColor:
                                  Colors.white, // Icon and text color
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: ListTile(
                          textColor: AppConstants.primaryTextColor,
                          tileColor: AppConstants.primaryColor,
                          title: Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.4, //solved by media query
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(customer.name,
                                            softWrap: true,
                                            style: const TextStyle(
                                                color: AppConstants
                                                    .primaryTextColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(customer.phone,
                                            softWrap: true,
                                            style: const TextStyle(
                                                color: AppConstants
                                                    .primaryTextColor,
                                                fontSize: 16)),
                                      ]),
                                ),
                                const Spacer(),
                                Text(customer.balance)
                              ],
                            ),
                          ),
                          // title: Text(customer.name),
                          // subtitle: Text(customer.phone),
                          // trailing: Text(customer.balance), // Adjust this to show actual balance if available
                          onTap: () {
                            Get.to(() => TransactionPage(
                                  token: user!.apiToken,
                                  branchId: user!.branchId,
                                  customerId: customer.id,
                                ));
                          },
                        ),
                      );
                    },
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  borderRadius: 15,
                  minWidth: 120,
                  height: 70,
                  text: "Add Customer",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Add Customer'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _nameController,
                                  decoration:
                                      InputDecoration(labelText: 'Name'),
                                ),
                                TextField(
                                  controller: _phoneController,
                                  decoration:
                                      InputDecoration(labelText: 'Phone'),
                                ),
                                TextField(
                                  controller: _emailController,
                                  decoration:
                                      InputDecoration(labelText: 'Email'),
                                ),
                                TextField(
                                  controller: _addressController,
                                  decoration:
                                      InputDecoration(labelText: 'Address'),
                                ),
                                TextField(
                                  controller: _areaController,
                                  decoration:
                                      InputDecoration(labelText: 'Area'),
                                ),
                                TextField(
                                  controller: _postCodeController,
                                  decoration:
                                      InputDecoration(labelText: 'Post Code'),
                                ),
                                TextField(
                                  controller: _cityController,
                                  decoration:
                                      InputDecoration(labelText: 'City'),
                                ),
                                TextField(
                                  controller: _stateController,
                                  decoration:
                                      InputDecoration(labelText: 'State'),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Create'),
                              onPressed: () {
                                _createCustomer();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
