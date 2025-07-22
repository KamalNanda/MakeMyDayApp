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
  const LikeButton({
    required this.postId,
    required this.likeCount,
    required this.likedByYou,
    this.onLiked,
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
    setState(() {
      _likedByYou = widget.likedByYou;
      _likeCount = widget.likeCount;
    });
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
        if (widget.onLiked != null) widget.onLiked!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to like post')),
        );
      }
    } catch (e) {
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                _likedByYou ? Icons.favorite : Icons.favorite_outline_outlined,
                color: _likedByYou ? Colors.redAccent : Colors.white,
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
