import 'package:google_fonts/google_fonts.dart';
import 'package:makemyday/screens/home/utils/post_model.dart';
import 'package:makemyday/screens/home/widgets/post/tags.dart';
import 'package:makemyday/screens/home/widgets/post/title.dart';
import 'package:flutter/material.dart';

// ignore_for_file: must_be_immutable
class Content extends StatefulWidget {
  PostModel post;

  Content(this.post);

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to top after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
  }

@override
void didUpdateWidget(covariant Content oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (oldWidget.post.id != widget.post.id) {
    // Reset scroll to top when post changes
    _scrollController.jumpTo(0);
  }
}
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.white,
        color: Color(0xFF20232B),
        borderRadius: BorderRadius.circular(16), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 2, // Extends the shadow
            blurRadius: 5, // Blurs the shadow
            offset: Offset(1, 20), // Moves shadow downwards
          ),
        ],
      ),
      // color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 20,),
            NewsTitle(widget.post.title),
            SizedBox(height: 8), // Spacing
            Tags(widget.post.tags),
            SizedBox(height: 8), // Spacing
            if(widget.post.type == 'news')
            Divider(
              color: const Color.fromARGB(255, 226, 226, 226),
              thickness: 2,
            ),
            SizedBox(height: 8), // Spacing
            Text(
              widget.post.description,
              style: GoogleFonts.raleway(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 320),
          ],
        ),
      ),
    );
  }
}
