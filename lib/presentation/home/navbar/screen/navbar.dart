// import 'dart:async';
// import 'package:app_links/app_links.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nex_music/bloc/connectivity_bloc/bloc/connectivity_bloc.dart';
// import 'package:nex_music/bloc/deep_link_bloc/bloc/deeplink_bloc.dart' as dp;
// import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
// import 'package:nex_music/core/theme/hexcolor.dart';
// import 'package:nex_music/core/ui_component/global_download_indicator.dart';
// import 'package:nex_music/enum/song_miniplayer_route.dart';
// import 'package:nex_music/helper_function/applink_function/uri_parser.dart';
// import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';
// import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
// import 'package:nex_music/presentation/audio_player/widget/overlay_audio_player.dart';
// import 'package:nex_music/presentation/favorites/screen/favorites_screen.dart';
// import 'package:nex_music/presentation/home/navbar/widget/navbarwidget.dart';
// import 'package:nex_music/presentation/home/navbar/widget/navrail.dart';
// import 'package:nex_music/presentation/home/screen/home_screen.dart';
// import 'package:nex_music/presentation/recent/screens/recentscreen.dart';
// import 'package:nex_music/core/ui_component/snackbar.dart';
// import 'package:nex_music/presentation/saved/screens/saved.dart';
// import 'package:nex_music/presentation/setting/screen/desktop_setting_tab.dart';
// import 'package:nex_music/presentation/user_playlist/screens/user_playlist.dart';

// final GlobalKey<OverlaySongPlayerState> overlayPlayerKey =
//     GlobalKey<OverlaySongPlayerState>();

// class NavBar extends StatefulWidget {
//   final AppLinks appLinks;
//   final FirebaseAuth firebaseAuth;

//   const NavBar({
//     super.key,
//     required this.appLinks,
//     required this.firebaseAuth,
//   });

//   @override
//   State<NavBar> createState() => _NavBarState();
// }

// class _NavBarState extends State<NavBar> with WidgetsBindingObserver {
//   late final List<Widget> screens;
//   int _selectedIndex = 0;
//   StreamSubscription<Uri>? streamSubscriptionUri;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ConnectivityBloc>().add(CheckConnectivityStatusEvent());

//       streamSubscriptionUri = widget.appLinks.uriLinkStream.listen((uri) {
//         if (uri.toString().isNotEmpty) {
//           if (!uri.toString().contains("playlist")) {
//             final songId = AppLinkUriParser.songUriParser(uri);
//             if (!mounted) return;
//             context.read<dp.DeeplinkBloc>().add(
//                   dp.GetDeeplinkSongDataEvent(songId: songId),
//                 );
//           } else {
//             final playlistId = AppLinkUriParser.playlistUrlParser(uri);
//             print(playlistId);
//             // Handle playlist if needed.
//           }
//         }
//       });
//     });

//     final currentUser = widget.firebaseAuth.currentUser!;
//     WidgetsBinding.instance.addObserver(this);

//     screens = [
//       HomeScreen(currentUser: currentUser), // Home
//       const RecentScreen(), // Recent
//       const UserPlaylist(), // Playlist
//       const FavoritesScreen(), // Favorites
//       const SavedSongs(), // downloads

//       DesktopSettingTab(
//         //setting for large screen device only
//         currentUser: currentUser,
//       ),
//     ];
//   }

//   @override
//   void didChangeDependencies() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     // On small screens (e.g., mobile), index 4 is only accessible via the Drawer.
//     // Reset to index 0 to avoid showing an inaccessible screen.
//     if (screenWidth < 451 && _selectedIndex == 4) {
//       _selectedIndex = 0;
//     }
//     super.didChangeDependencies();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     streamSubscriptionUri?.cancel();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       context.read<SongstreamBloc>().add(UpdateUIEvent());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     // breakpoint for the responsive layout.
//     final bool isSmallScreen = screenWidth < 451;

//     return PopScope(
//       canPop: _selectedIndex == 0,
//       onPopInvokedWithResult: (_, __) {
//         if (_selectedIndex != 0) {
//           setState(() {
//             _selectedIndex = 0;
//           });
//         }
//       },
//       child: Scaffold(
//         body: Row(
//           children: [
//             // For larger screens, show the side NavRail.
//             if (!isSmallScreen)
//               NavRail(
//                 selectedIndex: _selectedIndex,
//                 onTap: (index) {
//                   if (overlayPlayerKey.currentState?.mounted ?? false) {
//                     overlayPlayerKey.currentState?.closeOverlay();
//                   }
//                   setState(() {
//                     _selectedIndex = index;
//                   });
//                 },
//               ),
//             Expanded(
//               child: Stack(
//                 children: [
//                   IndexedStack(
//                     index: _selectedIndex,
//                     children: screens,
//                   ),
//                   BlocListener<dp.DeeplinkBloc, dp.DeeplinkState>(
//                     listener: (context, state) {
//                       if (state is dp.ErrorState) {
//                         showSnackbar(context, state.errorMessage);
//                       }
//                       if (state is dp.DeeplinkSongDataState) {
//                         Navigator.of(context).pushNamed(
//                           AudioPlayerScreen.routeName,
//                           arguments: {
//                             "songindex": -1,
//                             "songdata": state.songData,
//                             "route": SongMiniPlayerRoute.songRoute,
//                           },
//                         );
//                       }
//                     },
//                     child: const SizedBox.shrink(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         // Only show a bottom navigation bar for small screens.
//         bottomNavigationBar: isSmallScreen
//             ? Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   MiniPlayer(screenSize: screenSize),
//                   BlocBuilder<SongstreamBloc, SongstreamState>(
//                     buildWhen: (previous, current) => previous != current,
//                     builder: (context, state) {
//                       if (state is LoadingState ||
//                           state is PlayingState ||
//                           state is PausedState) {
//                         return const SizedBox();
//                       }
//                       return Divider(
//                         height: 4.5,
//                         thickness: 3,
//                         color: secondaryColor,
//                       );
//                     },
//                   ),
//                   NavBarWidget(
//                     screenSize: screenSize,
//                     selectedIndex: _selectedIndex,
//                     onTap: (index) {
//                       setState(() {
//                         _selectedIndex = index;
//                       });
//                     },
//                   ),
//                 ],
//               )
//             : // Hide MiniPlayer when overlay is mounted
//             MiniPlayer(screenSize: screenSize),
//         floatingActionButton: const GlobalDownloadIndicator(),
//       ),
//     );
//   }
// }

//===============================================================================

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/connectivity_bloc/bloc/connectivity_bloc.dart';
import 'package:nex_music/bloc/deep_link_bloc/bloc/deeplink_bloc.dart' as dp;
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/global_download_indicator.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/helper_function/applink_function/uri_parser.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/audio_player/widget/overlay_audio_player.dart';
import 'package:nex_music/presentation/favorites/screen/favorites_screen.dart';
import 'package:nex_music/presentation/home/navbar/widget/navbarwidget.dart';
import 'package:nex_music/presentation/home/navbar/widget/navrail.dart';
import 'package:nex_music/presentation/home/screen/home_screen.dart';
import 'package:nex_music/presentation/recent/screens/recentscreen.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/presentation/saved/screens/saved.dart';
import 'package:nex_music/presentation/setting/screen/desktop_setting_tab.dart';
import 'package:nex_music/presentation/user_playlist/screens/user_playlist.dart';

final GlobalKey<OverlaySongPlayerState> overlayPlayerKey =
    GlobalKey<OverlaySongPlayerState>();

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
  late final List<Widget?> screens;
  int _selectedIndex = 0;
  StreamSubscription<Uri>? streamSubscriptionUri;
  int count = 0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectivityBloc>().add(CheckConnectivityStatusEvent());

      streamSubscriptionUri = widget.appLinks.uriLinkStream.listen((uri) {
        if (uri.toString().isNotEmpty) {
          if (!uri.toString().contains("playlist")) {
            final songId = AppLinkUriParser.songUriParser(uri);
            if (!mounted) return;
            context.read<dp.DeeplinkBloc>().add(
                  dp.GetDeeplinkSongDataEvent(songId: songId),
                );
          } else {
            final playlistId = AppLinkUriParser.playlistUrlParser(uri);
            print(playlistId);
            // Handle playlist if needed.
          }
        }
      });
    });

    final currentUser = widget.firebaseAuth.currentUser!;
    WidgetsBinding.instance.addObserver(this);

    // Lazy initialization: only HomeScreen is initialized immediately
    screens = List.filled(6, null);
    screens[0] = HomeScreen(currentUser: currentUser);
  }

  @override
  void didChangeDependencies() {
    final screenWidth = MediaQuery.of(context).size.width;
    // On small screens (e.g., mobile), index 4 is only accessible via the Drawer.
    // Reset to index 0 to avoid showing an inaccessible screen.
    if (screenWidth < 451 && _selectedIndex == 4) {
      _selectedIndex = 0;
    }
    super.didChangeDependencies();
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
      context.read<SongstreamBloc>().add(UpdateUIEvent());
    }
  }

  void _onTabSelected(int index) {
    final currentUser = widget.firebaseAuth.currentUser!;

    setState(() {
      _selectedIndex = index;

      // Lazy load the screen only when accessed
      if (screens[index] == null) {
        switch (index) {
          case 1:
            screens[1] = const RecentScreen();
            break;
          case 2:
            screens[2] = const UserPlaylist();
            break;
          case 3:
            screens[3] = const FavoritesScreen();
            break;
          case 4:
            screens[4] = const SavedSongs();
            break;
          case 5:
            screens[5] = DesktopSettingTab(currentUser: currentUser);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // breakpoint for the responsive layout.
    final bool isSmallScreen = screenWidth < 451;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (_, __) {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            // For larger screens, show the side NavRail.
            if (!isSmallScreen)
              NavRail(
                selectedIndex: _selectedIndex,
                onTap: (index) {
                  if (overlayPlayerKey.currentState?.mounted ?? false) {
                    overlayPlayerKey.currentState?.closeOverlay();
                  }
                  _onTabSelected(index);
                },
              ),
            Expanded(
              child: Stack(
                children: [
                  IndexedStack(
                    index: _selectedIndex,
                    children: List.generate(
                      screens.length,
                      (index) => screens[index] ?? const SizedBox(),
                    ),
                  ),
                  BlocListener<dp.DeeplinkBloc, dp.DeeplinkState>(
                    listener: (context, state) {
                      if (state is dp.ErrorState) {
                        showSnackbar(context, state.errorMessage);
                      }
                      if (state is dp.DeeplinkSongDataState) {
                        Navigator.of(context).pushNamed(
                          AudioPlayerScreen.routeName,
                          arguments: {
                            "songindex": -1,
                            "songdata": state.songData,
                            "route": SongMiniPlayerRoute.songRoute,
                          },
                        );
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Only show the bottom navigation bar for small screens.
        bottomNavigationBar: isSmallScreen
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MiniPlayer(screenSize: screenSize),
                  BlocBuilder<SongstreamBloc, SongstreamState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      if (state is LoadingState ||
                          state is PlayingState ||
                          state is PausedState) {
                        return const SizedBox();
                      }
                      return Divider(
                        height: 4.5,
                        thickness: 3,
                        color: secondaryColor,
                      );
                    },
                  ),
                  NavBarWidget(
                    screenSize: screenSize,
                    selectedIndex: _selectedIndex,
                    onTap: _onTabSelected,
                  ),
                ],
              )
            : // Hide MiniPlayer when overlay is mounted
            MiniPlayer(screenSize: screenSize),
        floatingActionButton: const GlobalDownloadIndicator(),
      ),
    );
  }
}
