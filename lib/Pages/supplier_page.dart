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

class SupplierPage extends StatefulWidget {
  const SupplierPage({Key? key}) : super(key: key);

  @override
  _SupplierPageState createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final int type = 1; // 0 for Customer, 1 for Supplier

  String apiToken = user!.apiToken;
  int branchID = user!.branchId;
  bool isSupplierFetched = false;

  List<CustomerSupplier> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    final response = await http.get(
      Uri.parse(
          '${API.baseURL}/admin/${branchID}/$type/customers'),
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> suppliersData =
      responseData['customers']['customers'];

      setState(() {
        _suppliers =
            suppliersData.map((data) => CustomerSupplier.fromJson(data)).toList();
        isSupplierFetched = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch suppliers'),
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

  Future<void> _createSupplier() async {
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
        _fetchSuppliers(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create supplier'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.statusCode}'),
      ));
    }
  }

  Future<void> _updateSupplier(int supplierId) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '${API.baseURL}/admin/$branchID/customer/$supplierId/update'),
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
        _fetchSuppliers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update supplier'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.statusCode}'),
      ));
    }
  }

  Future<void> _deleteSupplier(int supplierId) async {
    final response = await http.delete(
      Uri.parse(
          '${API.baseURL}/admin/$branchID/customer/$supplierId/delete'),
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
        _fetchSuppliers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete supplier'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.statusCode}'),
      ));
    }
  }

  void showSupplierDialog({
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
    String? supplierId,
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
        appBar: AppConstants.appBarPrimary(title: "Suppliers"),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSupplierFetched
                ? Expanded(
              child: ListView.builder(
                itemCount: _suppliers.length,
                itemBuilder: (context, index) {
                  final supplier = _suppliers[index];
                  return Slidable(
                    key: ValueKey(supplier.id),
                    startActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _nameController.text = supplier.name;
                            _phoneController.text = supplier.phone;
                            _emailController.text = '';
                            _addressController.text = '';
                            _areaController.text = '';
                            _postCodeController.text = '';
                            _cityController.text = '';
                            _stateController.text = '';

                            showSupplierDialog(
                              context: context,
                              title: 'Update Supplier',
                              onAction: () => _updateSupplier(supplier.id),
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
                            _deleteSupplier(supplier.id);
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
                              Text(supplier.name,
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
                            Text(supplier.phone,
                                softWrap: true,
                                style: const TextStyle(
                                    color: AppConstants
                                        .primaryTextColor,
                                    fontSize: 16)),
                          ],
                        ),
                        trailing: Text("৳${supplier.balance}", style: TextStyle(fontSize:  16),),
                        onTap: () {
                          Get.to(() => TransactionPage(
                            token: user!.apiToken,
                            branchId: user!.branchId,
                            Id: supplier.id,
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
            showSupplierDialog(
              context: context,
              title: 'Add Supplier',
              onAction: _createSupplier,
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
