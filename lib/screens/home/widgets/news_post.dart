import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/screens/home/widgets/interactions/like_button.dart';
import 'package:makemyday/screens/home/widgets/interactions/share_button.dart';
import 'package:makemyday/screens/home/widgets/post/content.dart';
import 'package:makemyday/screens/home/widgets/post/date_tag.dart';
import 'package:makemyday/screens/home/widgets/post/image.dart';
import 'package:flutter/material.dart';

class NewsPost extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onLiked;
  const NewsPost(this.post, {this.onLiked, super.key});

  @override
  _NewsPostState createState() => _NewsPostState();
}

class _NewsPostState extends State<NewsPost> {
  @override
  void initState() {
    super.initState();
    print('initState: ' + widget.post.toJson().toString());
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.zero,
        color: Color(0xFFF9F7F4),
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(children: [ImageWidget(widget.post.media_url)]),
            ),
            Positioned(
              top: 170,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Content(widget.post),
              ),
            ),
            Positioned(
              top: 145,
              right: 80,
              child: LikeButton(
                postId: widget.post.id,
                likeCount: widget.post.like_count,
                likedByYou: widget.post.liked_by_you ?? false,
                onLiked: widget.onLiked,
              ),
            ),
            Positioned(
              top: 145,
              left: 20,
              child: DateTag(widget.post.created_at),
            ),
            Positioned(
              top: 145,
              right: 25,
              child: ShareButton(
                widget.post.id,
                widget.post.title,
                widget.post.media_url,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
