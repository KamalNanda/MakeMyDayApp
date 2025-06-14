import 'package:google_fonts/google_fonts.dart';
import 'package:makemyday/screens/home/widgets/interactions/interaction_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTag extends StatelessWidget {
  final String createdAt;
  DateTag(this.createdAt); 

  String formatDate(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);
    String day = DateFormat('d').format(parsedDate);
    String suffix = getDaySuffix(int.parse(day));
    String month = DateFormat('MMMM').format(parsedDate);

    return "$month $day$suffix";
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "th";
    }
    switch (day % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }
  @override
  Widget build(BuildContext context) {
    return InteractionButton(
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Text(createdAt.indexOf(':') != -1 ? formatDate(createdAt) : createdAt, style: GoogleFonts.raleway(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
} 
 