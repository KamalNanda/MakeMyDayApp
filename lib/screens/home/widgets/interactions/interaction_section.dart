import 'package:makemyday/screens/home/widgets/interactions/bookmark_button.dart';
// import 'package:makemyday/screens/home/widgets/interactions/comment_button.dart';
import 'package:makemyday/screens/home/widgets/interactions/like_button.dart';
import 'package:makemyday/screens/home/widgets/interactions/share_button.dart';
import 'package:flutter/material.dart';

class InteractionSection extends StatelessWidget {
  const InteractionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 200,
      right: 10,
      child: Column(
        children: [
          LikeButton(),
          BookmarkButton(),
          // ShareButton(),
          // CommentButton(),
        ],
      ),
    );
  }
}
