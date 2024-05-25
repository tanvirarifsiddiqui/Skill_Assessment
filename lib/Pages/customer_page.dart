import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:retina_soft_skill_test/Global/global_variables.dart';
import 'package:retina_soft_skill_test/Pages/transaction_page.dart';
import 'package:retina_soft_skill_test/constants/app_constants.dart';
import 'package:retina_soft_skill_test/models/customer_supplier_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';
import '../Services/api.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
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

  List<CustomerSupplier> _customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final response = await http.get(
      Uri.parse(
          '${API.baseURL}/admin/${branchID}/$type/customers'),
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
            customersData.map((data) => CustomerSupplier.fromJson(data)).toList();
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
          '${API.baseURL}/admin/$branchID/customer/create'),
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
          '${API.baseURL}/admin/$branchID/customer/$customerId/update'),
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
          '${API.baseURL}/admin/$branchID/customer/$customerId/delete'),
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

  void showCustomerDialog({
    required BuildContext context,
    required String title,
    required void Function() onAction,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController emailController,
    required TextEditingController addressController,
    required TextEditingController areaController,
    required TextEditingController postCodeController,
    required TextEditingController cityController,
    required TextEditingController stateController,
    String actionText = 'Create',
    String? customerId,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          shadowColor: AppConstants.primaryColor,
          backgroundColor: AppConstants.scaffoldBackgroundColor,
          title: Text(title,textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: areaController,
                  decoration: InputDecoration(labelText: 'Area'),
                ),
                TextField(
                  controller: postCodeController,
                  decoration: InputDecoration(labelText: 'Post Code'),
                ),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: stateController,
                  decoration: InputDecoration(labelText: 'State'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _clearForm();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(actionText),
              onPressed: () {
                onAction();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackgroundColor,
      appBar: AppConstants.appBarPrimary(title: "Customers"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

                                showCustomerDialog(
                                  context: context,
                                  title: 'Update Customer',
                                  onAction: () => _updateCustomer(customer.id),
                                  actionText: 'Update',
                                  nameController: _nameController,
                                  phoneController: _phoneController,
                                  emailController: _emailController,
                                  addressController: _addressController,
                                  areaController: _areaController,
                                  postCodeController: _postCodeController,
                                  cityController: _cityController,
                                  stateController: _stateController,
                                );
                              },
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
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
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                              backgroundColor: Colors
                                  .red, // Change this to your desired background color
                              foregroundColor:
                                  Colors.white, // Icon and text color
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1),
                          decoration: BoxDecoration(
                            gradient: AppConstants.secondaryGradient,
                            // color: AppConstants.primaryColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            textColor: AppConstants.primaryTextColor,
                            title: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.person,size: 20,color: AppConstants.primaryTextColor,),
                                  const SizedBox(width: 2,),
                                  Text(customer.name,
                                      softWrap: true,
                                      style: const TextStyle(
                                          color: AppConstants
                                              .primaryTextColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(Icons.phone,size: 20,color: AppConstants.primaryTextColor,),
                                SizedBox(width: 2,),
                                Text(customer.phone,
                                    softWrap: true,
                                    style: const TextStyle(
                                        color: AppConstants
                                            .primaryTextColor,
                                        fontSize: 16)),
                              ],
                            ),
                            trailing: Text("৳${customer.balance}", style: TextStyle(fontSize:  16),),
                            // title: Text(customer.name),
                            // subtitle: Text(customer.phone),
                            // trailing: Text(customer.balance), // Adjust this to show actual balance if available
                            onTap: () {
                              Get.to(() => TransactionPage(
                                    token: user!.apiToken,
                                    branchId: user!.branchId,
                                    Id: customer.id,
                                  ));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.secondaryColor,
        child: const Icon(
          color: AppConstants.primaryTextColor,
            Icons.add
        ),
        onPressed: () {
          showCustomerDialog(
            context: context,
            title: 'Add Customer',
            onAction: _createCustomer,
            actionText: 'Create',
            nameController: _nameController,
            phoneController: _phoneController,
            emailController: _emailController,
            addressController: _addressController,
            areaController: _areaController,
            postCodeController: _postCodeController,
            cityController: _cityController,
            stateController: _stateController,
          );
        },
      )
    );
  }
}
