    class PostModel {
      String id;
      final String title;
      final String description;
      List tags;
      int like_count; // Changed from String to int for better performance
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
          tags: _parseTags(json['tags']),
          like_count: _parseLikeCount(json['like_count']),
          type: json['type'],
          external_url: json['external_url'],
          media_url: json['media_url'],
          created_at: json['post_date'] ?? json['created_at'],
          liked_by_you: _parseLikedByYou(json['liked_by_you']),
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

      // Helper method to safely parse like_count from JSON
      static int _parseLikeCount(dynamic value) {
        if (value == null) return 0;

        if (value is int) return value;

        if (value is String) {
          return int.tryParse(value) ?? 0;
        }

        // Handle other numeric types
        if (value is double) return value.toInt();

        return 0;
      }

      // Helper method to safely parse liked_by_you from JSON
      static bool _parseLikedByYou(dynamic value) {
        if (value == null) return false;

        if (value is bool) return value;

        if (value is String) {
          return value.toLowerCase() == 'true';
        }

        if (value is int) {
          return value == 1;
        }

        return false;
      }

      // Helper method to safely parse tags from JSON
      static List _parseTags(dynamic value) {
        if (value == null) return [];

        if (value is List) return value;

        // Handle case where tags might be a single string
        if (value is String) {
          return [value];
        }

        return [];
      }
    }

    // New class to handle pagination response
    class PostsResponse {
      final bool status;
      final List<PostModel> posts;
      final PaginationInfo pagination;

      PostsResponse({
        required this.status,
        required this.posts,
        required this.pagination,
      });

      factory PostsResponse.fromJson(Map<String, dynamic> json) {
        return PostsResponse(
          status: json['status'] ?? false,
          posts:
              (json['data'] as List<dynamic>?)
                  ?.map((post) => PostModel.fromJson(post))
                  .toList() ??
              [],
          pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
        );
      }
    }

    // New class to handle pagination information
    class PaginationInfo {
      final int currentPage;
      final int totalPages;
      final int totalItems;
      final int pageSize;
      final bool hasNextPage;
      final bool hasPrevPage;

      PaginationInfo({
        required this.currentPage,
        required this.totalPages,
        required this.totalItems,
        required this.pageSize,
        required this.hasNextPage,
        required this.hasPrevPage,
      });

      factory PaginationInfo.fromJson(Map<String, dynamic> json) {
        return PaginationInfo(
          currentPage: _parseInt(json['currentPage'], 1),
          totalPages: _parseInt(json['totalPages'], 1),
          totalItems: _parseInt(json['totalItems'], 0),
          pageSize: _parseInt(json['pageSize'], 20),
          hasNextPage: _parseBool(json['hasNextPage'], false),
          hasPrevPage: _parseBool(json['hasPrevPage'], false),
        );
      }

      // Helper method to safely parse integers from JSON
      static int _parseInt(dynamic value, int defaultValue) {
        if (value == null) return defaultValue;

        if (value is int) return value;

        if (value is String) {
          return int.tryParse(value) ?? defaultValue;
        }

        if (value is double) return value.toInt();

        return defaultValue;
      }

      // Helper method to safely parse booleans from JSON
      static bool _parseBool(dynamic value, bool defaultValue) {
        if (value == null) return defaultValue;

        if (value is bool) return value;

        if (value is String) {
          return value.toLowerCase() == 'true';
        }

        if (value is int) {
          return value == 1;
        }

        return defaultValue;
      }
    }
