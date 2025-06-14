import 'package:google_fonts/google_fonts.dart';
import 'package:makemyday/screens/home/widgets/interactions/interaction_button.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InteractionButton( 
      child: Container(
        padding: EdgeInsets.all(8), 
        child: Row(
          children: [
            SizedBox(width: 5,),
            Text(
              '35',
              style: GoogleFonts.raleway(
                fontSize: 16,
              color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(width: 5,),
            Icon(
              Icons.favorite_outline_outlined,
              color: Colors.white,
              size: 24.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
          ],
        ),
      ),
    );
  }
}
