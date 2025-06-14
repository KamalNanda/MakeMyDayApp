import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  const CommentButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Icon(
        Icons.comment,
        color: Colors.white,
        size: 36.0,
        semanticLabel: 'Text to announce in accessibility modes',
      ),
    );
  }
}
