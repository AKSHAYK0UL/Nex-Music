import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/deep_link_bloc/bloc/deeplink_bloc.dart' as dp;
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/helper_function/applink_function/uri_parser.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/home/screen/home_screen.dart';
import 'package:nex_music/presentation/recent/screens/recentscreen.dart';

class NavBar extends StatefulWidget {
  final AppLinks appLinks;
  final FirebaseAuth firebaseAuth;

  const NavBar({
    super.key,
    required this.appLinks,
    required this.firebaseAuth,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with WidgetsBindingObserver {
  late List<Widget> screens;
  int _selectedIndex = 0;
  StreamSubscription<Uri>? streamSubscriptionUri;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      streamSubscriptionUri = widget.appLinks.uriLinkStream.listen((uri) {
        if (uri.toString().isNotEmpty) {
          if (!uri.toString().contains("playlist")) {
            final songId = AppLinkUriParser.songUriParser(uri);
            context.read<dp.DeeplinkBloc>().add(
                  dp.GetDeeplinkSongDataEvent(songId: songId),
                );
          } else {
            final playlistId = AppLinkUriParser.playlistUrlParser(uri);
            // Handle playlist if needed.
          }
        }
      });
    });

    final currentUser = widget.firebaseAuth.currentUser!;
    WidgetsBinding.instance.addObserver(this);
    screens = [
      HomeScreen(currentUser: currentUser), // Home
      const RecentScreen(), // Recent
      HomeScreen(currentUser: currentUser), // Favorites
      HomeScreen(currentUser: currentUser), // Playlist
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamSubscriptionUri?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SongstreamBloc>().add(UpdataUIEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.height;

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
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
            BlocListener<dp.DeeplinkBloc, dp.DeeplinkState>(
              listener: (context, state) {
                if (state is dp.ErrorState) {
                  showSnackbar(context, state.errorMessage);
                }
                if (state is dp.DeeplinkSongDataState) {
                  Navigator.of(context)
                      .pushNamed(AudioPlayerScreen.routeName, arguments: {
                    "songindex": -1,
                    "songdata": state.songData,
                    "route": SongMiniPlayerRoute.songRoute,
                  });
                }
              },
              child: const SizedBox.shrink(),
            ),
          ],
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
