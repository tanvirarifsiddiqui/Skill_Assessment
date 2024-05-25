import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:retina_soft_skill_test/Services/api.dart';
import 'dart:convert';
import 'package:retina_soft_skill_test/constants/app_constants.dart';
import 'package:retina_soft_skill_test/models/transaction_model.dart';

class TransactionPage extends StatefulWidget {
  final String token;
  final int branchId;
  final int Id;

  const TransactionPage({
    Key? key,
    required this.token,
    required this.branchId,
    required this.Id,
  }) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _transactionDateTimeController =
      TextEditingController();
  final int type = 1; // 0=you get, 1=you gave

  bool isDataFetched = false;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final response = await http.get(
      Uri.parse(
          '${API.baseURL}/admin/${widget.branchId}/customer/${widget.Id}/transactions'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _transactions = (responseData['transactions']['transactions'] as List)
            .map((transaction) => Transaction.fromJson(transaction))
            .toList();
        isDataFetched = true;
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
    request.fields['customer_id'] = widget.Id.toString();
    request.fields['amount'] = _amountController.text;
    request.fields['type'] = type.toString();
    request.fields['transaction_date'] = _transactionDateTimeController.text;
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
        _clearForm();
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
          '${API.baseURL}/admin/${widget.branchId}/customer/transaction/$transactionId/update'),
    );
    request.fields['amount'] = _amountController.text;
    request.fields['transaction_date'] = _transactionDateTimeController.text;
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
        _clearForm();
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
          '${API.baseURL}/admin/${widget.branchId}/customer/transaction/$transactionId/delete'),
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

  void _clearForm() {
    _amountController.clear();
    _detailsController.clear();
    _billNoController.clear();
    _transactionDateTimeController.clear();
  }

  double _calculateTotalBalance() {
    double total = 0.0;
    for (var transaction in _transactions) {
      total += double.parse(transaction.amount.toString());
    }
    return total;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          final DateTime pickedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _transactionDateTimeController.text = pickedDateTime.toString();
        });
      }
    }
  }

  void _showTransactionDialog({Transaction? transaction}) {
    if (transaction != null) {
      _amountController.text = transaction.amount.toString();

      final DateFormat dateFormat = DateFormat('dd MMM, yyyy hh:mm a');
      _transactionDateTimeController.text = dateFormat.format(transaction.transactionDate);

      _detailsController.text = transaction.details;
      _billNoController.text = transaction.billNo;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(transaction == null
              ? "Create Transaction"
              : "Update Transaction"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                InkWell(
                  onTap: () {
                    _selectDateTime(context);
                  },
                  child: IgnorePointer(
                    child: TextField(
                      controller: _transactionDateTimeController,
                      decoration: InputDecoration(
                        labelText: 'Transaction Date and Time',
                      ),
                    ),
                  ),
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
                _clearForm();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(transaction == null ? 'Create' : 'Update'),
              onPressed: () {
                if (transaction == null) {
                  _createTransaction();
                } else {
                  _updateTransaction(transaction.id);
                }
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
      appBar: AppConstants.appBarPrimary(title: "Transactions"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              // width: MediaQuery.of(context).size.width,
              // height: 75,
              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1),
              decoration: BoxDecoration(
                gradient: AppConstants.secondaryGradient,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ExpansionTile(
                textColor: AppConstants.primaryTextColor,
                iconColor: AppConstants.primaryTextColor,
                collapsedTextColor: AppConstants.primaryTextColor,
                collapsedIconColor: AppConstants.primaryTextColor,
                leading: Icon(CupertinoIcons.money_dollar_circle,size: 25,),
                title: Text("Total Amount ৳${_calculateTotalBalance()}", style:TextStyle(fontSize: 20),textAlign: TextAlign.center),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      border: TableBorder.all(color: AppConstants.primaryTextColor),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(3),
                        3: FlexColumnWidth(3),
                        4: FlexColumnWidth(3),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Trans No', style: const TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Bill No', style: const TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Date', style: const TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Time', style: const TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Amount', style: const TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        for (var transaction in _transactions) TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(transaction.transactionNo,style: TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(transaction.billNo,style: TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(DateFormat('dd MMM, yy').format(transaction.transactionDate),style: TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(DateFormat('hh:mm a').format(transaction.transactionDate),style: TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("৳${transaction.amount}",style: TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,)),
                            ),
                          ],
                        ),
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.2),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Total', style: const TextStyle(color:AppConstants.primaryTextColor,fontSize:12,fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("৳${_calculateTotalBalance()}", style: const TextStyle(color:AppConstants.primaryTextColor,fontSize: 12,fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ),
          isDataFetched
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return Slidable(
                        key: ValueKey(transaction.id),
                        startActionPane: ActionPane(
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _showTransactionDialog(
                                    transaction: transaction);
                              },
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(12)),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
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
                                _deleteTransaction(transaction.id);
                              },
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(12)),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 1),
                          decoration: BoxDecoration(
                            gradient: AppConstants.secondaryGradient,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ExpansionTile(
                            textColor: AppConstants.primaryTextColor,
                            iconColor: AppConstants.primaryTextColor,
                            collapsedTextColor: AppConstants.primaryTextColor,
                            collapsedIconColor: AppConstants.primaryTextColor,
                            title: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt,
                                      size: 20,
                                      color: AppConstants.primaryTextColor),
                                  const SizedBox(width: 5),
                                  Text(
                                      "Transaction \t${transaction.transactionNo}",
                                      softWrap: true,
                                      style: const TextStyle(
                                          color: AppConstants.primaryTextColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            subtitle: Row(

                              children: [
                                Icon(Icons.account_balance_wallet_outlined,size: 20,),
                                const SizedBox(width: 5),
                                Text("Amount \t৳${transaction.amount}",
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(1),
                                    1: FlexColumnWidth(2)
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        const TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                                            child: Row(
                                              children: [
                                                Icon(Icons.calendar_month_outlined,
                                                    size: 20,
                                                    color: AppConstants
                                                        .primaryTextColor),
                                                SizedBox(width: 5),
                                                Text("Date:",
                                                    style: TextStyle(
                                                        color: AppConstants
                                                            .primaryTextColor,
                                                        fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                                            child: Text(
                                              DateFormat('dd MMM, yyyy').format(
                                                  transaction.transactionDate),
                                              style: const TextStyle(
                                                  color: AppConstants
                                                      .primaryTextColor,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        const TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                                            child: Row(
                                              children: [
                                                Icon(Icons.access_time,
                                                    size: 20,
                                                    color: AppConstants
                                                        .primaryTextColor),
                                                SizedBox(width: 5),
                                                Text("Time:",
                                                    style: TextStyle(
                                                        color: AppConstants
                                                            .primaryTextColor,
                                                        fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                                            child: Text(
                                              DateFormat('hh:mm a').format(
                                                  transaction.transactionDate),
                                              style: const TextStyle(
                                                  color: AppConstants
                                                      .primaryTextColor,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        const TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                                            child: Row(
                                              children: [
                                                Icon(CupertinoIcons.number,
                                                    size: 20,
                                                    color: AppConstants
                                                        .primaryTextColor),
                                                SizedBox(width: 5),
                                                Text("Bill No:",
                                                    style: TextStyle(
                                                        color: AppConstants
                                                            .primaryTextColor,
                                                        fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                                            child: Text(transaction.billNo,
                                                softWrap: true,
                                                style: const TextStyle(
                                                    color: AppConstants
                                                        .primaryTextColor,
                                                    fontSize: 16)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        const TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 2.0, left: 8,right: 8,bottom: 8),
                                            child: Row(
                                              children: [
                                                Icon(CupertinoIcons.info,
                                                    size: 20,
                                                    color: AppConstants
                                                        .primaryTextColor),
                                                SizedBox(width: 5),
                                                Text("Details:",
                                                    style: TextStyle(
                                                        color: AppConstants
                                                            .primaryTextColor,
                                                        fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 2.0, left: 8,right: 8,bottom: 8),
                                            child: Text(transaction.details,
                                                softWrap: true,
                                                style: const TextStyle(
                                                    color: AppConstants
                                                        .primaryTextColor,
                                                    fontSize: 16)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*.35),
              child: Center(
                  child: CircularProgressIndicator()
              )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.secondaryColor,
        onPressed: () {
          _showTransactionDialog();
        },
        child: const Icon(color: AppConstants.primaryTextColor, Icons.add),
      ),
    );
  }
}
