import 'package:flutter/material.dart';
import 'package:retina_soft_skill_test/constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double minWidth;
  final double height;
  final double borderRadius;
  final Gradient gradient; // Added gradient parameter

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.minWidth = double.infinity,
    this.height = 50,
    this.borderRadius = 10,
    this.gradient = AppConstants.primaryGradient// Gradient is now a required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: minWidth,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Set primary to transparent to see the gradient
          shadowColor: Colors.transparent, // Remove shadow to prevent overlay
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints(
            minWidth: minWidth,
            minHeight: height,
          ),
          child: Text(
            textAlign: TextAlign.center,
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white), // Adjust text color as needed
          ),
        ),
      ),
    );
  }
}