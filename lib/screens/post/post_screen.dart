import 'package:flutter/material.dart';
import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/screens/home/widgets/news_post.dart';
import 'package:makemyday/screens/loading/loading_screen.dart';
import 'package:makemyday/utils/apiService.dart';
import 'package:makemyday/widgets/bottom_navigation/navigation.dart';

class PostScreen extends StatefulWidget {
  final String postId;
  const PostScreen({required this.postId, Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List _posts = [];

  void fetchData() async {
    ApiService apiService = ApiService();
    try {
      var data = await apiService.getRequest(
        "/mmd/v1/posts/fetch-post?id=${widget.postId}",
      );

      setState(() { 
        _posts.add(data['data']);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), fetchData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SizedBox.expand(
              child:
                  _posts.isNotEmpty
                      ? NewsPost(PostModel.fromJson(_posts[0]))
                      : Splash(),
            ),

            // Floating back button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Navigation()),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
