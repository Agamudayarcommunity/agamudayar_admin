enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

extension ApprovalStatusExtension on ApprovalStatus {
  String get name {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  String get color {
    switch (this) {
      case ApprovalStatus.pending:
        return '#FFA000'; // Amber
      case ApprovalStatus.approved:
        return '#22B04C'; // Green (AppColors.secondary)
      case ApprovalStatus.rejected:
        return '#F44336'; // Red
    }
  }
}