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
      child: Padding(
        padding: EdgeInsets.only(top: screenSize * 0.0028),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1
                  ? Icons.music_note
                  : Icons.music_note_outlined),
              label: 'Recent',
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 2
                  ? Icons.playlist_play_rounded
                  : Icons.playlist_play),
              label: 'Playlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 3
                  ? CupertinoIcons.heart_fill
                  : CupertinoIcons.heart),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 4
                  ? Icons.download
                  : Icons.download_outlined),
              label: 'Saved',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: onTap,
        ),
      ),
    );
  }
}
