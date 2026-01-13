import 'package:flutter/material.dart';
import 'package:peerpicks/common/app_colors.dart';

showMySnackBar({
  required BuildContext context,
  required String message,
  bool isError = false,
  required Color color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: AppColors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Roboto', // Ensuring font consistency
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? AppColors.error : color,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating, // Modern floating design
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
