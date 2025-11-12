import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/news_api_model.dart';
import '../models/news_status_model.dart';
import '../repositories/news_repository.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _newsRepository;
  StreamSubscription? _newsSubscription;

  NewsBloc({required NewsRepository newsRepository})
      : _newsRepository = newsRepository,
        super(NewsInitial()) {
    on<LoadNews>(_onLoadNews);
    on<UpdateNewsStatus>(_onUpdateNewsStatus);
    on<UpdateNewsStatusViaApi>(_onUpdateNewsStatusViaApi);
    on<AddSampleNews>(_onAddSampleNews);
    on<FetchNewsFromApi>(_onFetchNewsFromApi);
    on<ImportNewsFromApi>(_onImportNewsFromApi);
    on<FetchNewsStatusAll>(_onFetchNewsStatusAll);
    on<UpdateNewsStatusOnly>(_onUpdateNewsStatusOnly);
    on<UpdateNewsDetails>(_onUpdateNewsDetails);
  }

  Future<void> _onLoadNews(LoadNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      final news = event.filterStatus != null
          ? await _newsRepository.getNewsByStatus(event.filterStatus!)
          : await _newsRepository.getAllNews();
      
      emit(NewsLoaded(news));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  Future<void> _onUpdateNewsStatus(UpdateNewsStatus event, Emitter<NewsState> emit) async {
    try {
      await _newsRepository.updateNewsStatus(
        event.newsId,
        event.newStatus,
        rejectionReason: event.rejectionReason,
      );
      emit(NewsStatusUpdated());
      
      // Reload the news list
      if (state is NewsLoaded) {
        final loadedState = state as NewsLoaded;
        final updatedNews = loadedState.news.map((news) {
          if (news.id == event.newsId) {
            return news.copyWith(
              status: event.newStatus,
              rejectionReason: event.rejectionReason,
              approvedDate: event.newStatus.name == 'approved' ? DateTime.now() : null,
            );
          }
          return news;
        }).toList();
        emit(NewsLoaded(updatedNews));
      }
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
  
  Future<void> _onUpdateNewsStatusViaApi(UpdateNewsStatusViaApi event, Emitter<NewsState> emit) async {
    try {
      final message = await _newsRepository.updateNewsStatusOnly(
        event.newsId,
        event.status,
      );
      emit(NewsStatusUpdatedViaApi(message));
      
      // Reload the news list to reflect changes
      add(const LoadNews());
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
  
  Future<void> _onAddSampleNews(AddSampleNews event, Emitter<NewsState> emit) async {
    try {
      // Sample news functionality removed - using API only
      emit(NewsError('Sample news functionality not available'));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
  
  Future<void> _onFetchNewsFromApi(FetchNewsFromApi event, Emitter<NewsState> emit) async {
    emit(ApiNewsLoading());
    try {
      final apiNews = await _newsRepository.getAllNews();
      emit(ApiNewsLoaded(apiNews));
    } catch (e) {
      emit(NewsError('Failed to fetch news from API: ${e.toString()}'));
    }
  }
  
  Future<void> _onImportNewsFromApi(ImportNewsFromApi event, Emitter<NewsState> emit) async {
    emit(ApiNewsLoading());
    try {
      // Import functionality removed - using API directly
      emit(NewsError('Import functionality not available'));
    } catch (e) {
      emit(NewsError('Failed to import news from API: ${e.toString()}'));
    }
  }

  Future<void> _onFetchNewsStatusAll(FetchNewsStatusAll event, Emitter<NewsState> emit) async {
    emit(NewsStatusLoading());
    try {
      final newsList = await _newsRepository.getAllNews();
      // Convert NewsModel to NewsStatusModel for compatibility
      final newsStatusList = newsList.map((news) => NewsStatusModel(
        newsId: news.id,
        title: news.title,
        subtitle: news.category,
        status: news.status.name,
        location: 'API',
        image: news.imageUrl,
      )).toList();
      emit(NewsStatusLoaded(newsStatusList));
    } catch (e) {
      emit(NewsStatusError('Failed to fetch news status: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNewsStatusOnly(UpdateNewsStatusOnly event, Emitter<NewsState> emit) async {
    try {
      final message = await _newsRepository.updateNewsStatusOnly(
        event.newsId,
        event.status,
      );
      emit(NewsStatusUpdateSuccess(message));
      // Refresh the news status list after update
      add(const FetchNewsStatusAll());
    } catch (e) {
      emit(NewsStatusError('Failed to update news status: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNewsDetails(UpdateNewsDetails event, Emitter<NewsState> emit) async {
    try {
      final message = await _newsRepository.updateNewsDetails(event.updateData);
      emit(NewsDetailsUpdateSuccess(message));
      // Refresh the news status list after update
      add(const FetchNewsStatusAll());
    } catch (e) {
      emit(NewsStatusError('Failed to update news details: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _newsSubscription?.cancel();
    return super.close();
  }
}