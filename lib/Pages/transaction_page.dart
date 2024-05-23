import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:retina_soft_skill_test/constants/app_constants.dart';

class TransactionPage extends StatefulWidget {
  final String token;
  final int branchId;
  final int customerId;

  const TransactionPage({
    Key? key,
    required this.token,
    required this.branchId,
    required this.customerId,
  }) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _transactionDateController =
  TextEditingController();
  final int type = 1; // 0=you get, 1=you gave

  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final response = await http.get(
      Uri.parse(
          'https://skill-test.retinasoft.com.bd/api/v1/admin/${widget.branchId}/customer/${widget.customerId}/transactions'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _transactions = responseData['transactions']['transactions'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch transactions'),
        ),
      );
    }
  }

  Future<void> _createTransaction() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://skill-test.retinasoft.com.bd/api/v1/admin/${widget.branchId}/customer/transaction/create'),
    );
    request.fields['customer_id'] = widget.customerId.toString();
    request.fields['amount'] = _amountController.text;
    request.fields['type'] = type.toString();
    request.fields['transaction_date'] = DateTime.now().toString();
    request.fields['details'] = _detailsController.text;
    request.fields['bill_no'] = _billNoController.text;

    request.headers['Authorization'] = 'Bearer ${widget.token}';

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      if (responseData['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['description']),
          ),
        );
        _fetchTransactions(); // Refresh the transaction list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create transaction'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response.statusCode}'),
        ),
      );
    }
  }

  Future<void> _updateTransaction(int transactionId) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://skill-test.retinasoft.com.bd/api/v1/admin/${widget.branchId}/customer/transaction/$transactionId/update'),
    );
    request.fields['amount'] = _amountController.text;
    request.fields['transaction_date'] = _transactionDateController.text;
    request.fields['details'] = _detailsController.text;
    request.fields['bill_no'] = _billNoController.text;

    request.headers['Authorization'] = 'Bearer ${widget.token}';

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      if (responseData['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['description']),
          ),
        );
        _fetchTransactions(); // Refresh the transaction list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update transaction'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response.statusCode}'),
        ),
      );
    }
  }

  Future<void> _deleteTransaction(int transactionId) async {
    final response = await http.delete(
      Uri.parse(
          'https://skill-test.retinasoft.com.bd/api/v1/admin/${widget.branchId}/customer/transaction/$transactionId/delete'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['description']),
        ),
      );
      _fetchTransactions(); // Refresh the transaction list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete transaction'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConstants.appBarPrimary(title: "Transactions"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: const  Text("Create Transaction"),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextField(
                                  controller: _amountController,
                                  decoration: InputDecoration(labelText: 'Amount'),
                                ),
                                TextField(
                                  controller: _transactionDateController,
                                  decoration: InputDecoration(labelText: 'Transaction Date'),
                                ),
                                TextField(
                                  controller: _detailsController,
                                  decoration: InputDecoration(labelText: 'Details'),
                                ),
                                TextField(
                                  controller: _billNoController,
                                  decoration: InputDecoration(labelText: 'Bill No'),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Create'),
                              onPressed: () {
                                _createTransaction();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      }
                  );
                },
                child: Text('Create Transaction'),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 400, // specify a fixed height
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return ListTile(
                      title: Text('Transaction No: ${transaction['transaction_no']}'),
                      subtitle: Text('Amount: ${transaction['amount']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _amountController.text = transaction['amount'];
                              _transactionDateController.text =
                              transaction['transaction_date'];
                              _detailsController.text = transaction['details'];
                              _billNoController.text = transaction['bill_no'];
                              _updateTransaction(transaction['id']);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteTransaction(transaction['id']);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
