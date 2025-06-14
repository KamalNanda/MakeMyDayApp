import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class NewsTitle extends StatelessWidget {
  String _newsTitle;
  NewsTitle(this._newsTitle);
  @override
  Widget build(BuildContext context) {
    return Text(
      _newsTitle,
      style: GoogleFonts.raleway(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        // color: Colors.black,

        color: Colors.white
      ),
      overflow: TextOverflow.visible,
      maxLines: 10, //
    );
  }
}
