class NewsStatusModel {
  final String newsId;
  final String title;
  final String subtitle;
  final String status;
  final String location;
  final String image;

  const NewsStatusModel({
    required this.newsId,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.location,
    required this.image,
  });

  factory NewsStatusModel.fromJson(Map<String, dynamic> json) {
    return NewsStatusModel(
      newsId: json['newsId'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      status: json['status'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newsId': newsId,
      'title': title,
      'subtitle': subtitle,
      'status': status,
      'location': location,
      'image': image,
    };
  }

  NewsStatusModel copyWith({
    String? newsId,
    String? title,
    String? subtitle,
    String? status,
    String? location,
    String? image,
  }) {
    return NewsStatusModel(
      newsId: newsId ?? this.newsId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      location: location ?? this.location,
      image: image ?? this.image,
    );
  }
}