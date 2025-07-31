import 'package:firebase_auth/firebase_auth.dart';
import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/screens/home/widgets/news_post.dart';
import 'package:makemyday/screens/loading/loading_screen.dart';
import 'package:makemyday/utils/apiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List _posts = [];
  int post_index = 1;
  final CardSwiperController controller = CardSwiperController();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      ApiService apiService = ApiService();
      var data = await apiService.getRequest(
        "/mmd/v1/posts/fetch-posts?user_id=${FirebaseAuth.instance.currentUser?.uid}",
      );

      if (mounted) {
        setState(() {
          for (var post in data['data']) {
            // Prevent duplicate entries
            if (!_posts.any(
              (existingPost) => existingPost['id'] == post['id'],
            )) {
              _posts.add(post);
            }
          }
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

  Future<void> _fetchMoreData() async {
    if (!mounted || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      ApiService apiService = ApiService();
      var data = await apiService.getRequest(
        "/mmd/v1/posts/fetch-posts?user_id=${FirebaseAuth.instance.currentUser?.uid}",
      );

      if (mounted) {
        setState(() {
          for (var post in data['data']) {
            // Prevent duplicate entries
            if (!_posts.any(
              (existingPost) => existingPost['id'] == post['id'],
            )) {
              _posts.add(post);
            }
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
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

    if (currentIndex != null && currentIndex >= _posts.length - 2) {
      print('Loading more posts...');
      _fetchMoreData();
    }

    return true;
  }

  void _retry() {
    setState(() {
      _posts.clear();
      post_index = 1;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color.fromRGBO(73, 75, 76, 1), Color(0xFF20232B)],
            stops: [0.0, 1.0],
            center: Alignment.bottomCenter,
            radius: 2,
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
            SizedBox(height: 24),
            Text(
              'Loading amazing content...',
              style: TextStyle(
                color: Colors.white,
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

    if (_hasError && _posts.isEmpty) {
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
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
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

    if (_posts.isEmpty) {
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
                color: Colors.white,
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
                foregroundColor: Colors.white,
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

    return Stack(
      children: [
        // Main Card Swiper
        CardSwiper(
          controller: controller,
          numberOfCardsDisplayed: 1,
          backCardOffset: const Offset(10, 10),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          scale: 0.9,
          duration: const Duration(milliseconds: 500),
          cardsCount: _posts.length,
          onSwipe: _onSwipe,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            return AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: percentThresholdX.abs() > 0.1 ? 0.5 : 1,
              child: Transform.scale(
                scale: percentThresholdX.abs() > 0.1 ? 0.95 : 1,
                child: NewsPost(PostModel.fromJson(_posts[index])),
              ),
            );
          },
        ),

        // Loading indicator for more posts
        if (_isLoadingMore)
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading more posts...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    if (_posts.isEmpty) return SizedBox();

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
