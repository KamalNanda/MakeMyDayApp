import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/screens/home/widgets/news_post.dart';
import 'package:makemyday/screens/loading/loading_screen.dart';
import 'package:makemyday/utils/apiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _posts = [];
  int post_index = 1;
  final CardSwiperController controller = CardSwiperController();
  void fetchData() async {
    print(post_index);
    ApiService apiService = ApiService();
    try {
      var data = await apiService.getRequest("/mmd/v1/posts/fetch-posts");

      setState(() {
        for (var post in data['data']) {
          // Prevent duplicate entries
          if (!_posts.any((existingPost) => existingPost['id'] == post['id'])) {
            _posts.add(post);
          }
        }
      });
      print(_posts.length);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), fetchData);
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    print(
      'Swiped card $previousIndex to ${direction.name}. Now card $currentIndex is on top',
    );
    if (currentIndex != null && currentIndex >= _posts.length - 1) {
      print('inside if');
      setState(() {
        ++post_index;
      });

      Future.delayed(Duration(milliseconds: 200), () {
        fetchData(); // Preload next post before it's needed
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          _posts.isNotEmpty
              ? Stack(
                children: [
                  // Other widgets...
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color.fromRGBO(73, 75, 76, 1),
                            Color.fromARGB(255, 32, 35, 43),
                          ],
                          stops: [0.0, 1.0],
                          center: Alignment.bottomCenter,
                          radius: 2,
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
                        shape: const CircleBorder(),
                        tooltip: 'Go back to previous post',
                        onPressed: () {
                          controller.undo();
                          --post_index;
                        },
                        child: const Icon(Icons.undo, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
              : SizedBox(),
      // backgroundColor: const Color.fromARGB(255, 211, 211, 211),
        // backgroundColor: Color(0xFF20232B),
      backgroundColor: Colors.transparent,
      body:
          Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color.fromRGBO(73, 75, 76, 1),
              Color(0xFF20232B)
            ],
            stops: [0.0, 1.0],
            center: Alignment.bottomCenter,
            radius: 2,
          ),
        ),
            child: _posts.isNotEmpty
                ? CardSwiper(
                  controller: controller,
                  numberOfCardsDisplayed: 1,
                  backCardOffset: const Offset(10, 10),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  scale: 0.9, // Smooth scaling effect
                  duration: const Duration(
                    milliseconds: 500,
                  ), // Smooth transition
                  // curve: Curves.easeInOut, // Easing curve for smoothness
                  cardsCount: _posts.length,
                  onSwipe: _onSwipe,
                  cardBuilder: (
                    context,
                    index,
                    percentThresholdX,
                    percentThresholdY,
                  ) {
                    return AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      opacity:
                          percentThresholdX.abs() > 0.1 ? 0.5 : 1, // Fade effect
                      child: Transform.scale(
                        scale:
                            percentThresholdX.abs() > 0.1
                                ? 0.95
                                : 1, // Scale effect
                        child: NewsPost(PostModel.fromJson(_posts[index])),
                      ),
                    );
                  },
                )
                : Splash(),
          ),
    );
  }
}
