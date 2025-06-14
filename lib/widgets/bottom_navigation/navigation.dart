import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:makemyday/screens/profile/profile_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:makemyday/screens/bookmarks/bookmarks.dart';
import 'package:makemyday/screens/home/home.dart';
import 'package:makemyday/screens/search/search.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final List<Map<String, dynamic>> _pages = [
    {'page': SearchScreen(), 'title': 'Search'},
    {'page': HomeScreen(), 'title': 'Home'},
    {'page': BookmarksScreen(), 'title': 'Bookmarks'},
    {'page': ProfileScreen(), 'title': 'Profile'},
  ];

  int _selectedPageIndex = 1;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 32, 35, 43),
      body: SafeArea(child: _pages[_selectedPageIndex]['page']),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [
              Color.fromRGBO(73, 75, 76, 1),
              Color.fromARGB(255, 32, 35, 43),
            ],
            stops: [0.0, 1.0],
            center: Alignment.bottomCenter,
            radius: 2,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SalomonBottomBar(
          backgroundColor: Colors.transparent,
          currentIndex: _selectedPageIndex,
          onTap: _selectPage,
          selectedItemColor: const Color(0xFF47CAD2),
          unselectedItemColor: Colors.grey.shade400,
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.search_rounded),
              title:  Text("Search", style: GoogleFonts.raleway()),
              selectedColor: const Color(0xFF47CAD2),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.home_filled),
              title:  Text("Home", style: GoogleFonts.raleway()),
              selectedColor: const Color(0xFF47CAD2),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.bookmark_rounded),
              title:  Text("Bookmarks", style: GoogleFonts.raleway()),
              selectedColor: const Color(0xFF47CAD2),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.account_circle_rounded),
              title:  Text("Profile", style: GoogleFonts.raleway()),
              selectedColor: const Color(0xFF47CAD2),
            ),
          ],
        ),
      ),
    );
  }
}