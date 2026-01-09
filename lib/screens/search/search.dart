import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makemyday/utils/posts_api_service.dart';
import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/screens/post/post_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final PostsApiService _apiService = PostsApiService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _tags = [];
  List<PostModel> _posts = [];
  PaginationInfo? _pagination;
  String? _selectedTagId;
  String? _selectedTagName;
  bool _isLoadingTags = true;
  bool _isLoadingPosts = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTags() async {
    if (!mounted) return;

    setState(() {
      _isLoadingTags = true;
      _hasError = false;
    });

    try {
      final tags = await _apiService.fetchTags();

      if (mounted) {
        setState(() {
          _tags = tags;
          _isLoadingTags = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoadingTags = false;
        });
      }
    }
  }

  Future<void> _fetchPostsByTag(String tagId, String tagName) async {
    if (!mounted) return;

    setState(() {
      _isLoadingPosts = true;
      _selectedTagId = tagId;
      _selectedTagName = tagName;
      _posts = [];
      _pagination = null;
      _currentPage = 1;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      final response = await _apiService.fetchPostsByTag(
        tagId: tagId,
        page: 1,
        limit: 20,
        userId: userId,
      );

      if (mounted) {
        setState(() {
          _posts = response.posts;
          _pagination = response.pagination;
          _currentPage = 1;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (!mounted || _isLoadingMore || !(_pagination?.hasNextPage ?? false))
      return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      final response = await _apiService.fetchPostsByTag(
        tagId: _selectedTagId!,
        page: _currentPage + 1,
        limit: 20,
        userId: userId,
      );

      if (mounted) {
        setState(() {
          _posts.addAll(response.posts);
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
      _loadMorePosts();
    }
  }

  void _navigateToPost(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen(postId: post.id)),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedTagId = null;
      _selectedTagName = null;
      _posts = [];
      _pagination = null;
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf7f2ef),
      body: Column(
        children: [
          // Tags Section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTagId != null
                      ? 'Selected: $_selectedTagName'
                      : 'Browse by topics',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                if (_isLoadingTags)
                  Center(
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading topics...',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                else if (_hasError && _tags.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load tags',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _fetchTags,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  _buildTagsGrid(),
              ],
            ),
          ),

          // Posts Section
          if (_selectedTagId != null) Expanded(child: _buildPostsSection()),
        ],
      ),
    );
  }

  Widget _buildTagsGrid() {
    return Container(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4),
        itemCount: _tags.length,
        itemBuilder: (context, index) {
          final tag = _tags[index];
          final isSelected = tag['id'] == _selectedTagId;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              onTap: () => _fetchPostsByTag(tag['id'], tag['tag']),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color.fromARGB(15, 33, 149, 243)
                          : Color.fromARGB(255, 235, 230, 227),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isSelected
                          ? Border.all(
                            color: const Color.fromARGB(136, 33, 149, 243),
                            width: 1.5,
                          )
                          : Border.all(color: Color(0xFFf7f2ef), width: 0.5),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ]
                          : [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                164,
                                164,
                                164,
                              ).withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                ),
                child: Text(
                  '#${tag['tag']}',
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.black,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsSection() {
    if (_isLoadingPosts) {
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
              'Loading posts...',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_hasError && _posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              'Error loading posts',
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
              onPressed:
                  () => _fetchPostsByTag(_selectedTagId!, _selectedTagName!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.grey, size: 64),
            SizedBox(height: 16),
            Text(
              'No posts found',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try selecting a different tag',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchPostsByTag(_selectedTagId!, _selectedTagName!),
      color: Colors.black,
      backgroundColor: Color(0xFFf7f2ef),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == _posts.length) {
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
                      'Loading more posts...',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    if (_pagination != null) ...[
                      SizedBox(height: 4),
                      Text(
                        '(${_currentPage}/${_pagination!.totalPages})',
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          final post = _posts[index];
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
                                        color: Colors.grey[800],
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
                                    color: Colors.grey[800],
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
                                      : Colors.grey[400],
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${post.like_count}',
                              style: TextStyle(
                                color: Colors.grey[400],
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
