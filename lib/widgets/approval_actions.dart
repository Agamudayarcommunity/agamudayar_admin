import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../core/models/approval_status.dart';

class ApprovalActions extends StatelessWidget {
  final String? itemId;
  final ApprovalStatus status;
  final Function(String, ApprovalStatus)? onStatusChange;
  final Function()? onApprove;
  final Function()? onReject;
  final Function()? onView;

  const ApprovalActions({
    super.key,
    this.itemId,
    required this.status,
    this.onStatusChange,
    this.onApprove,
    this.onReject,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == ApprovalStatus.pending) ...[          
          IconButton(
            icon: const Icon(Icons.check_circle, color: Color(0xFF22B04C)), // AppColors.secondary
            tooltip: 'Approve',
            onPressed: onApprove ?? (itemId != null && onStatusChange != null 
              ? () => onStatusChange!(itemId!, ApprovalStatus.approved)
              : null),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Color(0xFFF44336)), // Red
            tooltip: 'Reject',
            onPressed: onReject ?? (itemId != null && onStatusChange != null 
              ? () => onStatusChange!(itemId!, ApprovalStatus.rejected)
              : null),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.visibility, color: Color(0xFF673AB7)), // AppColors.primary
          tooltip: 'View Details',
          onPressed: onView ?? (itemId != null && onStatusChange != null 
            ? () => onStatusChange!(itemId!, status)
            : null),
        ),
      ],
    );
  }
}