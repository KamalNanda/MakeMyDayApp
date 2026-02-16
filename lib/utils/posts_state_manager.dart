import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/utils/posts_api_service.dart';

class PostsStateManager {
  final PostsApiService _apiService = PostsApiService();

  List<PostModel> _posts = [];
  PaginationInfo? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  final int _pageSize = 20;

  // Getters
  List<PostModel> get posts => List.unmodifiable(_posts);
  PaginationInfo? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get hasMorePosts => _pagination?.hasNextPage ?? false;
  int get currentPage => _currentPage;
  int get totalPosts => _pagination?.totalItems ?? 0;

  /// Load initial posts (first page)
  Future<void> loadInitialPosts() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.fetchInitialPosts(limit: _pageSize);

      _posts = response.posts;
      _pagination = response.pagination;
      _currentPage = 1;

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Load more posts (next page)
  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !hasMorePosts) return;

    _setLoadingMore(true);

    try {
      final response = await _apiService.fetchNextPage(
        currentPage: _currentPage,
        limit: _pageSize,
      );

      // Add new posts to existing list
      _posts.addAll(response.posts);
      _pagination = response.pagination;
      _currentPage = response.pagination.currentPage;

      _setLoadingMore(false);
    } catch (e) {
      _setError(e.toString());
      _setLoadingMore(false);
    }
  }

  /// Refresh posts (reload from first page)
  Future<void> refreshPosts() async {
    _clearError();
    await loadInitialPosts();
  }

  /// Like a post and update local state
  Future<bool> likePost(String postId) async {
    try {
      final success = await _apiService.likePost(postId);

      if (success) {
        // Update local state
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final updatedPost = PostModel(
            id: _posts[postIndex].id,
            title: _posts[postIndex].title,
            description: _posts[postIndex].description,
            tags: _posts[postIndex].tags,
            like_count: _posts[postIndex].like_count + 1,
            type: _posts[postIndex].type,
            external_url: _posts[postIndex].external_url,
            media_url: _posts[postIndex].media_url,
            created_at: _posts[postIndex].created_at,
            liked_by_you: true,
          );
          _posts[postIndex] = updatedPost;
        }
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Unlike a post and update local state
  Future<bool> unlikePost(String postId) async {
    try {
      final success = await _apiService.unlikePost(postId);

      if (success) {
        // Update local state
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final updatedPost = PostModel(
            id: _posts[postIndex].id,
            title: _posts[postIndex].title,
            description: _posts[postIndex].description,
            tags: _posts[postIndex].tags,
            like_count:
                _posts[postIndex].like_count > 0
                    ? _posts[postIndex].like_count - 1
                    : 0,
            type: _posts[postIndex].type,
            external_url: _posts[postIndex].external_url,
            media_url: _posts[postIndex].media_url,
            created_at: _posts[postIndex].created_at,
            liked_by_you: false,
          );
          _posts[postIndex] = updatedPost;
        }
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Check if we should load more posts based on current index
  bool shouldLoadMore(int currentIndex) {
    return currentIndex >= _posts.length - 3 && hasMorePosts && !_isLoadingMore;
  }

  /// Update a specific post in the list
  void updatePost(int index, PostModel updatedPost) {
    if (index >= 0 && index < _posts.length) {
      _posts[index] = updatedPost;
    }
  }

  /// Clear all data
  void clear() {
    _posts.clear();
    _pagination = null;
    _currentPage = 1;
    _clearError();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setLoadingMore(bool loadingMore) {
    _isLoadingMore = loadingMore;
  }

  void _setError(String error) {
    _hasError = true;
    _errorMessage = error;
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }
}
