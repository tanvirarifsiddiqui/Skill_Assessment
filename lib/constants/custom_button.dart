import 'package:flutter/material.dart';

class TransactionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const TransactionButton({required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Background color
        minimumSize: Size(50, 30), // Width and height
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
