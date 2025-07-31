import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class NewsTitle extends StatelessWidget {
  final String _newsTitle;
  NewsTitle(this._newsTitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.05), Colors.transparent],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        _newsTitle,
        style: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.3,
          letterSpacing: -0.5,
        ),
        overflow: TextOverflow.visible,
        maxLines: 8,
      ),
    );
  }
}
