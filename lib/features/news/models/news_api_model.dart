class NewsApiModel {
  final String id;
  final String title;
  final String subtitle;
  final String contentMessage;
  final String location;
  final String image;
  final List<String> images;
  final String status;
  final String newsId;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewsApiModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.contentMessage,
    required this.location,
    required this.image,
    required this.images,
    required this.status,
    required this.newsId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsApiModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else if ((json['image'] ?? '').toString().isNotEmpty) {
      parsedImages = [json['image'].toString()];
    }
    return NewsApiModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      contentMessage: json['contentMessage'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      images: parsedImages,
      status: json['status'] ?? 'pending',
      newsId: json['newsId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'subtitle': subtitle,
      'contentMessage': contentMessage,
      'location': location,
      'image': image,
      'images': images,
      'status': status,
      'newsId': newsId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert API model to app's NewsModel format
  Map<String, dynamic> toNewsModelMap() {
    final List<String> urls = images.isNotEmpty
        ? images
        : (image.isNotEmpty ? [image] : <String>[]);
    return {
      'id': newsId,
      'title': title,
      'content': contentMessage,
      'imageUrl': urls.isNotEmpty ? urls.first : 'https://via.placeholder.com/300x200',
      'imageUrls': urls,
      'category': subtitle,
      'submittedBy': 'API User',
      'submittedDate': createdAt,
      'status': status,
    };
  }
}