class PostModel {
  final String id;
  final String title;
  final String description;
  final List tags;
  final String type;
  final String external_url;
  final String media_url;
  final String created_at;

  PostModel({required this.id, required this.title, required this.description, required this.tags,required this.type,required this.external_url, required this.media_url, required this.created_at});

  // Factory constructor to create an instance from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      tags: json['tags'],
      type: json['type'],
      external_url: json['external_url'],
      media_url: json['media_url'],
      created_at: json['post_date'] == null ? json['created_at'] : json['post_date']
    );
  }
}