// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Tags extends StatelessWidget {
  List _tags;
  Tags(this._tags); 
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // Horizontal spacing
      runSpacing: 4.0, // Vertical spacing
      children:
          _tags.map((tag) {
            return Tag(tag);
          }).toList(),
    );
  }
}

class Tag extends StatelessWidget {
  final String _tag;
  Tag(this._tag);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color.fromRGBO(73, 75, 76, 1),
            Color.fromARGB(255, 54, 56, 67),
          ],
          stops: [0.0, 1.0],
          center: Alignment.bottomCenter,
          radius: 3,
        ),
        borderRadius: BorderRadius.all(Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          _tag,
          style:  GoogleFonts.raleway(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
    );
  }
}