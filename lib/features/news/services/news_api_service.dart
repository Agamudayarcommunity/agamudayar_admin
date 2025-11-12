import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsApiService {
  //'https://agamudayar.co.in/api/v1/'
  static const String prodBaseUrl = 'https://agamudayar.co.in/agamudayarbe/api/v1/';
  final String baseUrl = prodBaseUrl;

  // Fetch news data from the API
  Future<List<Map<String, dynamic>>> fetchNewsData() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}news/status/all'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load news data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news data: $e');
    }
  }

  // Fetch a single news item by ID
  Future<Map<String, dynamic>> fetchNewsById(String id) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}news/$id'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load news item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news item: $e');
    }
  }

  // Update news status via API
  Future<Map<String, dynamic>> updateNewsStatus(String newsId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}news/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'newsId': newsId,
          'status': status,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update news status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating news status: $e');
    }
  }

  // Fetch all news status data from API
  Future<List<dynamic>> fetchNewsStatusAll() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}news/status/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data;
      } else {
        throw Exception('Failed to fetch news status data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news status data: $e');
    }
  }

  // Update news status via API
  Future<String> updateNewsStatusOnly(String newsId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}news/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'newsId': newsId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? 'News status updated successfully';
      } else {
        throw Exception('Failed to update news status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating news status: $e');
    }
  }

  // Update news details via API
  Future<String> updateNewsDetails(Map<String, dynamic> updateData) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}news/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? 'News updated successfully';
      } else {
        throw Exception('Failed to update news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating news: $e');
    }
  }

  // Update full news details per new API contract
  Future<Map<String, dynamic>> updateNews({
    required String newsId,
    String? status,
    String? title,
    String? subtitle,
    String? contentMessage,
    String? location,
    List<String>? images,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'newsId': newsId,
      };

      if (status != null) payload['status'] = status;
      if (title != null) payload['title'] = title;
      if (subtitle != null) payload['subtitle'] = subtitle;
      if (contentMessage != null) payload['contentMessage'] = contentMessage;
      if (location != null) payload['location'] = location;
      if (images != null) payload['images'] = images;

      final response = await http.post(
        Uri.parse('${baseUrl}news/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating news: $e');
    }
  }
}