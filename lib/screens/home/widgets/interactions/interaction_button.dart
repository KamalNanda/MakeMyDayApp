import 'package:flutter/material.dart';

class InteractionButton extends StatelessWidget {
  final Widget child;

  // Constructor to accept a child widget
  const InteractionButton({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100), // Reduce border radius
      ),
      child: Container(
        decoration: BoxDecoration(
          // gradient: RadialGradient(
          //   colors: [
          //     Color.fromRGBO(73, 75, 76, 1),
          //     Color.fromARGB(255, 54, 56, 67),
          //   ],
          //   stops: [0.0, 1.0],
          //   center: Alignment.bottomCenter,
          //   radius: 3,
          // ),
          color: Color(0xFFf7f2ef),
          borderRadius: BorderRadius.all(Radius.circular(100)),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 5,
          //     offset: Offset(0.5, 0.5),
          //   ),
          // ],
        ),
        child: child,
      ),
    );
  }
}
