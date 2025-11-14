import 'package:flutter/material.dart';
import '../../../core/models/approval_status.dart';
import '../models/news_model.dart';
import '../repositories/news_repository.dart';

class NewsProvider extends ChangeNotifier {
  final NewsRepository _newsRepository = NewsRepository();

  List<NewsModel> _news = [];
  bool _isLoading = false;
  String? _error;

  List<NewsModel> get news => _news;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NewsProvider() {
    // Load news from API when provider is created
    loadNews();
  }

  // Statistics getters
  int get pendingCount =>
      _news.where((item) => item.status == ApprovalStatus.pending).length;

  int get approvedCount =>
      _news.where((item) => item.status == ApprovalStatus.approved).length;

  int get rejectedCount =>
      _news.where((item) => item.status == ApprovalStatus.rejected).length;

  // Load news data from API only
  Future<void> loadNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiNews = await _newsRepository.getAllNews();
      _news = apiNews;
      _error = null;
    } catch (e) {
      _error = 'Failed to load news: $e';
      _news = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Parse status string to ApprovalStatus enum
  ApprovalStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }

  Future<void> refreshNews() async {
    await loadNews();
  }

  Future<void> updateNewsStatus(
    String newsId,
    ApprovalStatus status, {
    String? rejectionReason,
  }) async {
    try {
      // Call API to update status
      String statusString = status.name;
      await _newsRepository.updateNewsStatusOnly(newsId, statusString);

      // Update local data
      final index = _news.indexWhere((item) => item.id == newsId);
      if (index != -1) {
        _news[index] = _news[index].copyWith(
          status: status,
          rejectionReason: rejectionReason,
          approvedDate: status == ApprovalStatus.approved
              ? DateTime.now()
              : null,
        );
        notifyListeners();
      }

      // Show success message
      _error = null;
    } catch (e) {
      _error = 'Failed to update news status: $e';
      notifyListeners();
    }
  }

  Future<void> updateNewsDetails(Map<String, dynamic> updateData) async {
    try {
      // Call API to update full news details
      final message = await _newsRepository.updateNewsDetails(updateData);

      // Update local data if news item exists
      final String newsId = updateData['newsId'] ?? '';
      final index = _news.indexWhere((item) => item.id == newsId);
      if (index != -1) {
        final current = _news[index];
        _news[index] = current.copyWith(
          title: updateData['title'] ?? current.title,
          content: updateData['contentMessage'] ?? current.content,
          imageUrl:
              (updateData['images'] is List &&
                  (updateData['images'] as List).isNotEmpty)
              ? (updateData['images'] as List).first
              : current.imageUrl,
          imageUrls: (updateData['images'] is List)
              ? (updateData['images'] as List)
                    .map((e) => e?.toString() ?? '')
                    .where((e) => e.isNotEmpty || e == '')
                    .toList()
              : current.imageUrls,
          category: updateData['subtitle'] ?? current.category,
          status: _parseStatus(updateData['status']) ?? current.status,
        );
        notifyListeners();
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to update news details: $e';
      notifyListeners();
    }
  }

  NewsModel? getNewsById(String id) {
    try {
      return _news.firstWhere((item) => item.id == id);
    } catch (e) {
      return null; // Not found
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
