
import 'package:flutter/material.dart';  

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({ Key? key }) : super(key: key);

  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Bookmarks'),
    );
  }
}