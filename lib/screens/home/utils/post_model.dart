class PostModel {
  String id;
  final String title;
  final String description;
  List tags;
  String like_count;
  final String type;
  final String external_url;
  final String media_url;
  final String created_at;
  bool liked_by_you;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.like_count,
    required this.type,
    required this.external_url,
    required this.media_url,
    required this.created_at,
    this.liked_by_you = false,
  });

  // Factory constructor to create an instance from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      tags: json['tags'],
      like_count: json['like_count'],
      type: json['type'],
      external_url: json['external_url'],
      media_url: json['media_url'],
      created_at: json['post_date'] ?? json['created_at'],
      liked_by_you: json['liked_by_you'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'tags': tags,
    'like_count': like_count,
    'type': type,
    'external_url': external_url,
    'media_url': media_url,
    'created_at': created_at,
    'liked_by_you': liked_by_you,
  };
}
