import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/screens/home/widgets/interactions/like_button.dart';
import 'package:makemyday/screens/home/widgets/interactions/share_button.dart';
import 'package:makemyday/screens/home/widgets/post/content.dart';
import 'package:makemyday/screens/home/widgets/post/date_tag.dart';
import 'package:makemyday/screens/home/widgets/post/image.dart';
import 'package:makemyday/screens/home/widgets/post/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart'; // Import media kit for player
import 'package:makemyday/utils/constants.dart' as globals;

class NewsPost extends StatefulWidget {
  final PostModel post;
  NewsPost(this.post);

  @override
  _NewsPostState createState() => _NewsPostState();
}

class _NewsPostState extends State<NewsPost> {
  Player? player; // Store the video player

  @override
  void initState() {
    super.initState();
    if (widget.post.type == 'video') {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    player = Player(); // Create new player
    player!.open(Media(widget.post.media_url), play: true);
  }

  @override
  void didUpdateWidget(covariant NewsPost oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the post changes, dispose old player and load new one
    if (oldWidget.post.media_url != widget.post.media_url) {
      _disposePlayer();
      if (widget.post.type == 'video') {
        _initializePlayer();
      }
    }
  }

  void _disposePlayer() {
    player?.dispose();
    player = null;
  }

  @override
  void dispose() {
    _disposePlayer(); // Ensure cleanup when widget is removed
    super.dispose();
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
        color: Color(0xFF20232B),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  if (widget.post.type == 'news')
                    ImageWidget(widget.post.media_url)
                  else
                    VideoWidget(
                      widget.post.media_url,
                      player!,
                    ), // Pass the player
                ],
              ),
            ),
            Positioned(
              top:
                  widget.post.type == 'news'
                      ? 170
                      : 170 + globals.video_widget_height_constant,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Content(widget.post),
              ),
            ),
            Positioned(
              top:
                  widget.post.type == 'news'
                      ? 145
                      : 145 + globals.video_widget_height_constant,
              right: 80,
              child: LikeButton(),
            ),
            Positioned(
              top:
                  widget.post.type == 'news'
                      ? 145
                      : 145 + globals.video_widget_height_constant,
              left: 20,
              child: DateTag(widget.post.created_at),
            ),
            Positioned(
              top:
                  widget.post.type == 'news'
                      ? 145
                      : 145 + globals.video_widget_height_constant,
              right: 25,
              child: ShareButton(
                widget.post.id,
                widget.post.title,
                widget.post.type != 'video'
                    ? widget.post.media_url
                    : 'https://ik.imagekit.io/hbj42mvqwv/openart-image_7Kcert0U_1738085355305_raw1-Photoroom_VDjL4DuHGf%20(1)_ucJm7C33z.png', // fallback for video
              ),
            ),
          ],
        ),
      ),
    );
  }
}
