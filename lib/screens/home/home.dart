import 'package:makemyday/screens/home/widgets/news_post.dart';
import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/utils/posts_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostsStateManager _postsManager = PostsStateManager();
  final CardSwiperController controller = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _loadInitialPosts();
  }

  Future<void> _loadInitialPosts() async {
    if (!mounted) return;

    await _postsManager.loadInitialPosts();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadMorePosts() async {
    if (!mounted) return;

    await _postsManager.loadMorePosts();
    if (mounted) {
      setState(() {});
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    print(
      'Swiped card $previousIndex to ${direction.name}. Now card $currentIndex is on top',
    );

    // Load more posts when approaching the end
    if (currentIndex != null && _postsManager.shouldLoadMore(currentIndex)) {
      print('Loading more posts...');
      _loadMorePosts();
    }

    return true;
  }

  void _onPostStateChanged(int postIndex, int likeCount, bool likedByYou) {
    // Update the PostModel in the manager
    final post = _postsManager.posts[postIndex];
    final updatedPost = PostModel(
      id: post.id,
      title: post.title,
      description: post.description,
      tags: post.tags,
      like_count: likeCount,
      type: post.type,
      external_url: post.external_url,
      media_url: post.media_url,
      created_at: post.created_at,
      liked_by_you: likedByYou,
    );
    
    // Update the posts list
    _postsManager.updatePost(postIndex, updatedPost);
    if (mounted) {
      setState(() {});
    }
  }

  void _retry() {
    _postsManager.clear();
    _loadInitialPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF9F7F4)),
        child: _buildBody(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    if (_postsManager.isLoading) {
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
            SizedBox(height: 24),
            Text(
              'Loading amazing content...',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Discovering posts just for you',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_postsManager.hasError && _postsManager.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: Icon(Icons.wifi_off_rounded, color: Colors.red, size: 48),
            ),
            SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _postsManager.errorMessage,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_postsManager.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
            ),
            SizedBox(height: 24),
            Text(
              'No posts available',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new content',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _postsManager.refreshPosts();
        if (mounted) setState(() {});
      },
      color: Colors.blue,
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          // Main Card Swiper
          CardSwiper(
            controller: controller,
            numberOfCardsDisplayed: 1,
            backCardOffset: const Offset(10, 10),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            scale: 0.9,
            duration: const Duration(milliseconds: 500),
            cardsCount: _postsManager.posts.length,
            onSwipe: _onSwipe,
            cardBuilder: (
              context,
              index,
              percentThresholdX,
              percentThresholdY,
            ) {
              return AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: percentThresholdX.abs() > 0.1 ? 0.5 : 1,
                child: Transform.scale(
                  scale: percentThresholdX.abs() > 0.1 ? 0.95 : 1,
                  child: NewsPost(
                    _postsManager.posts[index],
                    postIndex: index,
                    onStateChange: _onPostStateChanged,
                  ),
                ),
              );
            },
          ),

          // Loading indicator for more posts
          if (_postsManager.isLoadingMore)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading more posts...',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      if (_postsManager.pagination != null) ...[
                        SizedBox(width: 8),
                        Text(
                          '(${_postsManager.currentPage}/${_postsManager.pagination!.totalPages})',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_postsManager.posts.isEmpty) return SizedBox();

    return Stack(
      children: [
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: CircleBorder(),
              tooltip: 'Go back to previous post',
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.undo();
              },
              child: Icon(Icons.undo, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
