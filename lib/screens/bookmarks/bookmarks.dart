import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makemyday/utils/posts_api_service.dart';
import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/screens/post/post_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final PostsApiService _apiService = PostsApiService();
  final ScrollController _scrollController = ScrollController();

  List<PostModel> _likedPosts = [];
  PaginationInfo? _pagination;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialLikedPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLikedPosts() async {
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _apiService.fetchLikedPosts(page: 1, limit: 20);

      if (mounted) {
        setState(() {
          _likedPosts = response.posts;
          _pagination = response.pagination;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreLikedPosts() async {
    if (!mounted || _isLoadingMore || !(_pagination?.hasNextPage ?? false))
      return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _apiService.fetchLikedPosts(
        page: _currentPage + 1,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          _likedPosts.addAll(response.posts);
          _pagination = response.pagination;
          _currentPage = response.pagination.currentPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreLikedPosts();
    }
  }

  Future<void> _refreshLikedPosts() async {
    await _loadInitialLikedPosts();
  }

  void _navigateToPost(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: post.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf7f2ef),
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFf7f2ef),
        elevation: 0,
        actions: [
          if (_pagination != null && !_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  '${_currentPage}/${_pagination!.totalPages}',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshLikedPosts,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your bookmarks...',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              'Error loading bookmarks',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshLikedPosts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_likedPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, color: Colors.grey, size: 64),
            SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Posts you like will appear here',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Swipe right on posts to like them!',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshLikedPosts,
      color: Colors.black,
      backgroundColor: Color(0xFFf7f2ef),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        itemCount: _likedPosts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == _likedPosts.length) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Loading more bookmarks...',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    if (_pagination != null) ...[
                      SizedBox(height: 4),
                      Text(
                        '(${_currentPage}/${_pagination!.totalPages})',
                        style: TextStyle(color: Colors.black54, fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          final post = _likedPosts[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFFf7f2ef),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => _navigateToPost(post),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post media
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      child:
                          post.type == 'video'
                              ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    post.media_url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.black54,
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.black,
                                          size: 48,
                                        ),
                                      );
                                    },
                                  ),
                                  Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.black,
                                    size: 48,
                                  ),
                                ],
                              )
                              : Image.network(
                                post.media_url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.black54,
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.black,
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                    ),
                  ),

                  // Post content
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          post.description,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12),

                        // Tags
                        if (post.tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children:
                                post.tags.map<Widget>((tag) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Color(0xFFf7f2ef),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 0.5,
                                          offset: Offset(0.5, 0.5),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),

                        SizedBox(height: 12),

                        // Post metadata
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color:
                                  post.liked_by_you
                                      ? Colors.red
                                      : Colors.black54,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${post.like_count}',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            Spacer(),
                            Text(
                              post.created_at,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
