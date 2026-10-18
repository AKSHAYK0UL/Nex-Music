import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final double screenSize;
  const NavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        bottomNavigationBarTheme: Theme.of(context).bottomNavigationBarTheme,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        iconSize: 20,
        selectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recent',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.music_albums_fill),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (index) => onTap(index),
      ),
    );
  }
}
