import 'package:flutter/material.dart';
import '../core/models/approval_status.dart';
import '../config/theme.dart';

class StatusBadge extends StatelessWidget {
  final ApprovalStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = AppColors.white;

    switch (status) {
      case ApprovalStatus.pending:
        backgroundColor = const Color(0xFFFFA000); // Amber
        break;
      case ApprovalStatus.approved:
        backgroundColor = AppColors.secondary; // Green
        break;
      case ApprovalStatus.rejected:
        backgroundColor = const Color(0xFFF44336); // Red
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}