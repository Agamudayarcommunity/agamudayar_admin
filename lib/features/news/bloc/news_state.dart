import 'package:equatable/equatable.dart';
import '../models/news_model.dart';
import '../models/news_status_model.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsModel> news;

  const NewsLoaded(this.news);

  @override
  List<Object?> get props => [news];
}

class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}

class NewsStatusUpdated extends NewsState {}

class NewsStatusUpdatedViaApi extends NewsState {
  final String message;
  
  const NewsStatusUpdatedViaApi(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ApiNewsLoading extends NewsState {}

class ApiNewsLoaded extends NewsState {
  final List<dynamic> apiNews;
  
  const ApiNewsLoaded(this.apiNews);
  
  @override
  List<Object?> get props => [apiNews];
}

class ApiNewsImported extends NewsState {
  final int count;
  
  const ApiNewsImported(this.count);
  
  @override
  List<Object?> get props => [count];
}

class NewsStatusLoading extends NewsState {}

class NewsStatusLoaded extends NewsState {
  final List<NewsStatusModel> newsStatusList;
  
  const NewsStatusLoaded(this.newsStatusList);
  
  @override
  List<Object?> get props => [newsStatusList];
}

class NewsStatusError extends NewsState {
  final String message;
  
  const NewsStatusError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class NewsStatusUpdateSuccess extends NewsState {
  final String message;
  
  const NewsStatusUpdateSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class NewsDetailsUpdateSuccess extends NewsState {
  final String message;
  
  const NewsDetailsUpdateSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}