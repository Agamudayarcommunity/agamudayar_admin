import 'package:equatable/equatable.dart';
import '../../../core/models/approval_status.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNews extends NewsEvent {
  final ApprovalStatus? filterStatus;

  const LoadNews({this.filterStatus});

  @override
  List<Object?> get props => [filterStatus];
}

class UpdateNewsStatus extends NewsEvent {
  final String newsId;
  final ApprovalStatus newStatus;
  final String? rejectionReason;

  const UpdateNewsStatus({
    required this.newsId,
    required this.newStatus,
    this.rejectionReason,
  });
  
  @override
  List<Object?> get props => [newsId, newStatus, rejectionReason];
}

class FetchNewsFromApi extends NewsEvent {
  const FetchNewsFromApi();
}

class ImportNewsFromApi extends NewsEvent {
  const ImportNewsFromApi();
}

class AddSampleNews extends NewsEvent {}

class UpdateNewsStatusViaApi extends NewsEvent {
  final String newsId;
  final String status;

  const UpdateNewsStatusViaApi({
    required this.newsId,
    required this.status,
  });
  
  @override
  List<Object?> get props => [newsId, status];
}

class FetchNewsStatusAll extends NewsEvent {
  const FetchNewsStatusAll();
}

class UpdateNewsStatusOnly extends NewsEvent {
  final String newsId;
  final String status;

  const UpdateNewsStatusOnly({
    required this.newsId,
    required this.status,
  });
  
  @override
  List<Object?> get props => [newsId, status];
}

class UpdateNewsDetails extends NewsEvent {
  final Map<String, dynamic> updateData;

  const UpdateNewsDetails({
    required this.updateData,
  });
  
  @override
  List<Object?> get props => [updateData];
}