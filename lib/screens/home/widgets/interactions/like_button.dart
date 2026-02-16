import 'package:google_fonts/google_fonts.dart';
import 'package:makemyday/screens/home/widgets/interactions/interaction_button.dart';
import 'package:flutter/material.dart';
import 'package:makemyday/utils/apiService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeButton extends StatefulWidget {
  final String postId;
  final int likeCount;
  final bool likedByYou;
  final VoidCallback? onLiked;
  final Function(int, bool)? onStateChange; // Callback to notify parent of state changes
  const LikeButton({
    required this.postId,
    required this.likeCount,
    required this.likedByYou,
    this.onLiked,
    this.onStateChange,
    Key? key,
  }) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late int _likeCount;
  late bool _likedByYou;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likeCount;
    _likedByYou = widget.likedByYou;
  }

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the post ID changed (swiped to different post)
    // Don't override local state if it's the same post
    if (oldWidget.postId != widget.postId) {
      setState(() {
        _likedByYou = widget.likedByYou;
        _likeCount = widget.likeCount;
      });
    }
  }

  Future<void> _likePost() async {
    if (_likedByYou || _loading) return;
    setState(() {
      _loading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');
      final userId = user.uid;
      final api = ApiService();
      final response = await api.postRequest('/mmd/v1/posts/like-post', {
        'post_id': widget.postId,
        'user_id': userId,
      });
      if (response != null && response['status'] == true) {
        setState(() {
          _likeCount += 1;
          _likedByYou = true;
        });
        // Notify parent of state change
        if (widget.onStateChange != null) {
          widget.onStateChange!(_likeCount, _likedByYou);
        }
        if (widget.onLiked != null) widget.onLiked!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?['message'] ?? 'Failed to like post')),
        );
      }
    } catch (e) {
      print('Error liking post: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _likePost,
      child: InteractionButton(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(width: 5),
              Text(
                '$_likeCount',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                _likedByYou ? Icons.favorite : Icons.favorite_outline_outlined,
                color: _likedByYou ? Colors.redAccent : Color(0xff6B5B4A),
                size: 24.0,
                semanticLabel: 'Like',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
