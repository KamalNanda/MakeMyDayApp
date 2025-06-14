import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ImageWidget extends StatelessWidget {
  String media_url;
  ImageWidget(this.media_url);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      child: Image.network(
        media_url,
        fit: BoxFit.cover,
        width: double.infinity, 
        height: 190,
      ),
    );
  }
}
 