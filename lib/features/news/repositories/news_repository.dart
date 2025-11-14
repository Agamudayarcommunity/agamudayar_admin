import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../models/news_model.dart';
import '../models/news_api_model.dart';
import '../services/news_api_service.dart';
import '../../../core/models/approval_status.dart';

class NewsRepository {
  final NewsApiService _apiService = NewsApiService();

  // Get all news items from API
  Future<List<NewsModel>> getAllNews() async {
    try {
      final apiNewsData = await _apiService.fetchNewsStatusAll();
      final apiNews = apiNewsData
          .map((item) => NewsApiModel.fromJson(item))
          .toList();
      return apiNews.map((apiModel) => _convertToNewsModel(apiModel)).toList();
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }

  // Convert NewsApiModel to NewsModel
  NewsModel _convertToNewsModel(NewsApiModel apiModel) {
    final List<String> urls = apiModel.images.isNotEmpty
        ? apiModel.images
        : (apiModel.image.isNotEmpty ? [apiModel.image] : <String>[]);
    return NewsModel(
      id: apiModel.newsId,
      title: apiModel.title,
      content: apiModel.contentMessage,
      imageUrl: urls.isNotEmpty
          ? urls.first
          : 'https://via.placeholder.com/300x200',
      imageUrls: urls,
      category: apiModel.subtitle.isNotEmpty ? apiModel.subtitle : 'General',
      submittedBy: 'API User',
      submittedDate: apiModel.createdAt,
      status: _parseStatus(apiModel.status),
    );
  }

  // Parse status string to ApprovalStatus enum
  ApprovalStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }

  // Get news items by status
  Future<List<NewsModel>> getNewsByStatus(ApprovalStatus status) async {
    try {
      final allNews = await getAllNews();
      return allNews.where((news) => news.status == status).toList();
    } catch (e) {
      throw Exception('Failed to fetch news by status: $e');
    }
  }

  // Get a single news item from API
  Future<NewsModel?> getNewsById(String id) async {
    try {
      final allNews = await getAllNews();
      return allNews.firstWhere((news) => news.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update news status via API only
  Future<void> updateNewsStatus(
    String id,
    ApprovalStatus status, {
    String? rejectionReason,
  }) async {
    try {
      await updateNewsStatusOnly(id, status.name);
    } catch (e) {
      throw Exception('Failed to update news status: $e');
    }
  }

  // Update news status only via API
  Future<String> updateNewsStatusOnly(String newsId, String status) async {
    try {
      final message = await _apiService.updateNewsStatusOnly(newsId, status);
      return message;
    } catch (e) {
      throw Exception('Failed to update news status: $e');
    }
  }

  // Update news details via API
  Future<String> updateNewsDetails(Map<String, dynamic> updateData) async {
    try {
      final message = await _apiService.updateNewsDetails(updateData);
      return message;
    } catch (e) {
      throw Exception('Failed to update news details: $e');
    }
  }

  Future<NewsModel> saveEditedNews({
    required String newsId,
    required String title,
    required String content,
    List<PlatformFile>? newImages, // <-- FIX: Changed from XFile
  }) async {
    try {
      List<http.MultipartFile> imageFiles = [];

      if (newImages != null && newImages.isNotEmpty) {
        for (var file in newImages) {
          // This logic handles both Web and Mobile file uploads
          imageFiles.add(
            http.MultipartFile.fromBytes(
              'images', // This MUST match your backend's multer key
              file.bytes!, // Use the file bytes
              filename: file.name,
              contentType: MediaType.parse(
                lookupMimeType(file.name) ?? 'application/octet-stream',
              ),
            ),
          );
        }
      }

      // Call the API service to upload everything
      final updatedNewsMap = await _apiService.uploadNewsUpdate(
        newsId: newsId,
        title: title,
        content: content,
        imageFiles: imageFiles.isNotEmpty ? imageFiles : null,
      );

      // Convert the raw API data back into our clean app model
      final apiModel = NewsApiModel.fromJson(updatedNewsMap);
      return _convertToNewsModel(apiModel);
    } catch (e) {
      throw Exception('Failed to save news details: $e');
    }
  }
}
