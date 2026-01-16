// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Tags extends StatelessWidget {
  final List _tags;
  Tags(this._tags, {super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0, // Horizontal spacing
      runSpacing: 8.0, // Vertical spacing
      children:
          _tags.map((tag) {
            if(tag.trim().isEmpty) return SizedBox.shrink();
            return Tag(tag);
          }).toList(),
    );
  }
}

class Tag extends StatefulWidget {
  final String _tag;
  const Tag(this._tag, {super.key});

  @override
  State<Tag> createState() => _TagState();
}

class _TagState extends State<Tag> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                //   colors: [
                //     Color.fromRGBO(73, 75, 76, 0.9),
                //     Color.fromARGB(255, 54, 56, 67),
                //   ],
                // ),
                color: Color(0xFFf7f2ef),
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 0.5,
                    offset: Offset(0.5, 0.5),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container(
                  //   width: 6,
                  //   height: 6,
                  //   decoration: BoxDecoration(
                  //     color: Colors.blue,
                  //     shape: BoxShape.circle,
                  //   ),
                  // ),
                  // SizedBox(width: 8),
                  Text(
                    widget._tag,
                    style: GoogleFonts.inter(
                      color: Color(0xff6B5B4A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
