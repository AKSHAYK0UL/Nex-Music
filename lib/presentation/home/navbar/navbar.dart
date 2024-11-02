import 'package:flutter/material.dart';
import 'package:nex_music/presentation/home/screen/home_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  List<Widget> screens = const [
    //TODO
    HomeScreen(), //home
    HomeScreen(), //recent
    HomeScreen(), //fav
    HomeScreen(), //playlist
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          bottomNavigationBarTheme: Theme.of(context).bottomNavigationBarTheme,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: screenSize * 0.0028),
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'Recent',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.playlist_play),
                label: 'Playlist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Favorite',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(
                () {
                  _selectedIndex = index;
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
