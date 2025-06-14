import 'package:flutter/material.dart';

class BookmarkButton extends StatelessWidget {
  const BookmarkButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Icon(
        Icons.bookmark_outline,
        color: Colors.white,
        size: 36.0,
        semanticLabel: 'Text to announce in accessibility modes',
      ),
    );
  }
}
