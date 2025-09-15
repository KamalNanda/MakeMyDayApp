import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makemyday/screens/home/utils/post_model.dart';

class PostsApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://makemydaybackend-production.up.railway.app",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  /// Fetch posts with pagination support
  /// [page] - Page number (default: 1)
  /// [limit] - Number of posts per page (default: 20, max: 100)
  /// [userId] - User ID for personalized data (optional)
  Future<PostsResponse> fetchPosts({
    int page = 1,
    int limit = 20,
    String? userId,
  }) async {
    try {
      // Ensure limit doesn't exceed maximum
      limit = limit > 100 ? 100 : limit;

      // Build query parameters
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      // Add user ID if provided
      if (userId != null && userId.isNotEmpty) {
        queryParams['user_id'] = userId;
      }

      final response = await _dio.get(
        '/mmd/v1/posts/fetch-posts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PostsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch posts: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // If we get a 404 or server error, try the old endpoint as fallback
      if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
        return await _fetchPostsFallback(
          page: page,
          limit: limit,
          userId: userId,
        );
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fallback method to fetch posts using the old endpoint
  Future<PostsResponse> _fetchPostsFallback({
    int page = 1,
    int limit = 20,
    String? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null && userId.isNotEmpty) {
        queryParams['user_id'] = userId;
      }

      final response = await _dio.get(
        '/mmd/v1/posts/fetch-posts-by-pagination',
        queryParameters: {...queryParams, 'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return PostsResponse.fromJson(response.data);
      } else {
        throw Exception('Fallback also failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Both endpoints failed: $e');
    }
  }

  /// Fetch posts for the current user with pagination
  Future<PostsResponse> fetchPostsForCurrentUser({
    int page = 1,
    int limit = 20,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    try {
      return await fetchPosts(
        page: page,
        limit: limit,
        userId: currentUser?.uid,
      );
    } catch (e) {
      // If the request fails, try without user_id as fallback
      if (e.toString().contains('404') ||
          e.toString().contains('Failed to fetch posts')) {
        return await fetchPosts(page: page, limit: limit);
      }
      rethrow;
    }
  }

  /// Fetch initial posts (first page)
  Future<PostsResponse> fetchInitialPosts({int limit = 20}) {
    return fetchPostsForCurrentUser(page: 1, limit: limit);
  }

  /// Fetch next page of posts
  Future<PostsResponse> fetchNextPage({
    required int currentPage,
    int limit = 20,
  }) {
    return fetchPostsForCurrentUser(page: currentPage + 1, limit: limit);
  }

  /// Like a post
  Future<bool> likePost(String postId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.post(
        '/mmd/v1/posts/like-post',
        data: {'post_id': postId, 'user_id': currentUser.uid},
      );

      return response.statusCode == 200 && response.data['status'] == true;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  /// Unlike a post
  Future<bool> unlikePost(String postId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.delete(
        '/mmd/v1/posts/like-post',
        data: {'post_id': postId, 'user_id': currentUser.uid},
      );

      return response.statusCode == 200 && response.data['status'] == true;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.receiveTimeout:
        return Exception('Request timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';
        return Exception('Server error ($statusCode): $message');
      case DioExceptionType.connectionError:
        return Exception(
          'Connection error. Please check your internet connection.',
        );
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}
