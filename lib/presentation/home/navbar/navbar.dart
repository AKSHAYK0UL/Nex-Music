import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/bloc_provider/repository_provider/repository_provider.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/home/screen/home_screen.dart';
import 'package:nex_music/presentation/recent/screens/recentscreen.dart';

class NavBar extends StatefulWidget {
  final RepositoryProviderClass repositoryProviderClassInstance;
  const NavBar({
    super.key,
    required this.repositoryProviderClassInstance,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with WidgetsBindingObserver {
  late List<Widget> screens;
  int _selectedIndex = 0;
  @override
  void initState() {
    final currentUser = widget
        .repositoryProviderClassInstance.getFirebaseAuthInstance.currentUser!;
    WidgetsBinding.instance.addObserver(this);
    screens = [
      HomeScreen(currentUser: currentUser), // home
      const RecentScreen(), // recent
      HomeScreen(currentUser: currentUser), // favorites
      HomeScreen(currentUser: currentUser), // playlist
    ];
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SongstreamBloc>().add(UpdataUIEvent());
      print("**********************Foreground********************");
    }
  }

  @override
  Widget build(BuildContext contexts) {
    final screenSize = MediaQuery.sizeOf(contexts).height;
    return PopScope(
      canPop: _selectedIndex == 0 ? true : false,
      onPopInvokedWithResult: (_, __) {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MiniPlayer(screenSize: screenSize),
            Theme(
              data: ThemeData(
                bottomNavigationBarTheme:
                    Theme.of(context).bottomNavigationBarTheme,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: screenSize * 0.0028),
                child: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(_selectedIndex == 0
                          ? Icons.home
                          : Icons.home_outlined),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(_selectedIndex == 1
                          ? Icons.music_note
                          : Icons.music_note_outlined),
                      label: 'Recent',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(_selectedIndex == 2
                          ? Icons.playlist_play_rounded
                          : Icons.playlist_play),
                      label: 'Playlist',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(_selectedIndex == 3
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart),
                      label: 'Favorites',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
