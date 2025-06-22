// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
// import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart' as ss;
// import 'package:nex_music/core/theme/hexcolor.dart';
// import 'package:nex_music/core/ui_component/loading.dart';
// import 'package:nex_music/presentation/auth/screens/user_info.dart' as user;
// import 'package:nex_music/presentation/home/screen/showallplaylists.dart';
// import 'package:nex_music/presentation/home/widget/home_playlist.dart';
// import 'package:nex_music/presentation/home/widget/songcolumview.dart';
// import 'package:nex_music/presentation/search/screens/search_screen.dart';
// import 'package:nex_music/presentation/search/widgets/desktop_searchbar.dart';
// import 'package:nex_music/presentation/setting/screen/settting.dart';

// class HomeScreen extends StatefulWidget {
//   final User currentUser;
//   const HomeScreen({
//     super.key,
//     required this.currentUser,
//   });

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.sizeOf(context).height;
//     final screenWidth = MediaQuery.sizeOf(context).width;
//     bool isSmallScreen = screenWidth < 451;

//     return BlocBuilder<HomesectionBloc, HomesectionState>(
//       buildWhen: (previous, current) => previous != current,
//       builder: (context, state) {
//         if (state is LoadingState) {
//           return const Loading();
//         }
//         if (state is ErrorState) {
//           return Center(
//             child: Text(
//               state.errorMessage,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           );
//         }
//         if (state is HomeSectionState) {
//           context
//               .read<ss.SongstreamBloc>()
//               .add(ss.GetSongPlaylistEvent(songlist: state.quickPicks));
//           context
//               .read<ss.SongstreamBloc>() //store the quicks picks
//               .add(ss.StoreQuickPicksSongsEvent(quickPicks: state.quickPicks));
//           return Stack(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   FocusScope.of(context).unfocus();
//                 },
//                 child: Scaffold(
//                   appBar: AppBar(
//                     actions: [
//                       if (!isSmallScreen) const SizedBox(),
//                       if (isSmallScreen)
//                         IconButton(
//                           onPressed: () {
//                             Navigator.of(context)
//                                 .pushNamed(SearchScreen.routeName);
//                           },
//                           icon: Icon(
//                             size: screenSize * 0.0369,
//                             Icons.search,
//                             color: Colors.white,
//                           ),
//                         ),
//                       if (isSmallScreen)
//                         Builder(builder: (context) {
//                           return PopupMenuButton(
//                               shape: RoundedRectangleBorder(
//                                 side:
//                                     BorderSide(color: accentColor, width: 1.5),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               color: secondaryColor,
//                               constraints: const BoxConstraints(
//                                   maxHeight: 150,
//                                   maxWidth: 130,
//                                   minHeight: 110,
//                                   minWidth: 130),
//                               itemBuilder: (context) => [
//                                     PopupMenuItem(
//                                       child: Row(
//                                         spacing: 10,
//                                         children: [
//                                           const Icon(
//                                             Icons.person,
//                                           ),
//                                           Text(
//                                             "Profile",
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .titleMedium,
//                                           ),
//                                         ],
//                                       ),
//                                       onTap: () {
//                                         Navigator.of(context).pushNamed(
//                                             user.UserInfo.routeName,
//                                             arguments: widget.currentUser);
//                                       },
//                                     ),
//                                     PopupMenuItem(
//                                       child: Row(
//                                         spacing: 10,
//                                         children: [
//                                           const Icon(Icons.settings),
//                                           Text(
//                                             "Setting",
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .titleMedium,
//                                           ),
//                                         ],
//                                       ),
//                                       onTap: () {
//                                         Navigator.of(context).pushNamed(
//                                             QualitySettingsScreen.routeName);
//                                       },
//                                     ),
//                                   ]);
//                         })
//                     ],
//                     title: Visibility(
//                       visible: isSmallScreen,
//                       child: Padding(
//                         padding: EdgeInsets.only(left: screenSize * 0.0158),
//                         child: const Text(
//                           //"Quick Picks",
//                           "Discover",
//                         ),
//                       ),
//                     ),
//                     centerTitle: isSmallScreen ? false : true,
//                   ),
//                   body: SingleChildScrollView(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: screenSize * 0.0106,
//                           vertical: screenSize * 0.0053),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (!isSmallScreen)
//                             AppBar(
//                               title: const Text(
//                                   // "Quick Picks",
//                                   "Discover"),

//                               actions: const [
//                                 SizedBox()
//                               ], //to hide the drawer icon
//                             ),
//                           SizedBox(
//                             height: screenSize * 0.440, //435
//                             child: ListView.builder(
//                               shrinkWrap: true,
//                               scrollDirection: Axis.horizontal,
//                               itemCount: (state.quickPicks.length / 4)
//                                   .ceil(), // Calculate the number of horizontal items
//                               itemBuilder: (context, rowIndex) {
//                                 return SongColumView(
//                                   rowIndex: rowIndex,
//                                   quickPicksLength: state.quickPicks.length,
//                                   quickPicks: state.quickPicks,
//                                 );
//                               },
//                             ),
//                           ),
//                           if (isSmallScreen)
//                             Padding(
//                               padding:
//                                   EdgeInsets.only(left: screenSize * 0.0106),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     //"Playlists For You",
//                                     "Recommended playlists",
//                                     style:
//                                         Theme.of(context).textTheme.titleLarge,
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.of(context).pushNamed(
//                                           ShowAllPlaylists.routeName);
//                                     },
//                                     child: Container(
//                                       color: Colors.transparent,
//                                       width: screenSize * 0.080,
//                                       alignment: Alignment.topRight,
//                                       child: Icon(
//                                         Icons.arrow_forward_ios,
//                                         color: Colors.white,
//                                         size: screenSize * 0.0290,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           if (!isSmallScreen)
//                             Padding(
//                               padding: EdgeInsets.only(
//                                 left: screenSize * 0.0106,
//                                 top: screenSize * 0.0206,
//                                 bottom: screenSize * 0.0100,
//                               ),
//                               child: Text(
//                                 //"Playlists For You",
//                                 "Recommended playlists",
//                                 style: Theme.of(context).textTheme.titleLarge,
//                               ),
//                             ),
//                           if (isSmallScreen)
//                             SizedBox(
//                               height: screenSize * 0.345,
//                               child: ListView.builder(
//                                 shrinkWrap: true,
//                                 scrollDirection: Axis.horizontal,
//                                 itemCount: state.playlist.length >= 6
//                                     ? 6
//                                     : state.playlist.length,
//                                 itemBuilder: (context, index) {
//                                   final playlistData = state.playlist[index];
//                                   return HomePlaylist(playList: playlistData);
//                                 },
//                               ),
//                             ),
//                           if (!isSmallScreen)
//                             GridView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: state.playlist.length,
//                               gridDelegate:
//                                   const SliverGridDelegateWithMaxCrossAxisExtent(
//                                       maxCrossAxisExtent: 300),
//                               itemBuilder: (context, index) {
//                                 final playlistData = state.playlist[index];
//                                 return HomePlaylist(playList: playlistData);
//                               },
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Visibility(
//                 visible: !isSmallScreen,
//                 child: const Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: DesktopSearchBar(),
//                 ),
//               ),
//             ],
//           );
//         }
//         return const SizedBox();
//       },
//     );
//   }
// }

//================================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart' as ss;
import 'package:nex_music/bloc/think_bloc/bloc/think_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/loading.dart';
import 'package:nex_music/presentation/auth/screens/user_info.dart' as user;
import 'package:nex_music/presentation/home/screen/showallplaylists.dart';
import 'package:nex_music/presentation/home/widget/home_playlist.dart';
import 'package:nex_music/presentation/home/widget/songcolumview.dart';
import 'package:nex_music/presentation/search/screens/search_screen.dart';
import 'package:nex_music/presentation/setting/screen/settting.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;
  const HomeScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());

    //TODO:
    //Test THINK
    context.read<ThinkBloc>().add(LoadRecentSongsInThink());
    //Test THINK

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    // final screenWidth = MediaQuery.sizeOf(context).width;

    return BlocBuilder<HomesectionBloc, HomesectionState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return const Loading();
        }
        if (state is ErrorState) {
          return Center(
            child: Text(
              state.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        if (state is HomeSectionState) {
          context
              .read<ss.SongstreamBloc>()
              .add(ss.GetSongPlaylistEvent(songlist: state.quickPicks));
          context
              .read<ss.SongstreamBloc>() //store the quicks picks
              .add(ss.StoreQuickPicksSongsEvent(quickPicks: state.quickPicks));
          return Scaffold(
            appBar: AppBar(
              title: Padding(
                padding: EdgeInsets.only(left: screenSize * 0.0158),
                child: const Text(
                  //"Quick Picks",
                  "Discover",
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(SearchScreen.routeName);
                  },
                  icon: Icon(
                    size: screenSize * 0.0369,
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
                Builder(
                  builder: (context) {
                    return PopupMenuButton(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: accentColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: secondaryColor,
                      constraints: const BoxConstraints(
                          maxHeight: 150,
                          maxWidth: 130,
                          minHeight: 110,
                          minWidth: 130),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            spacing: 10,
                            children: [
                              const Icon(
                                Icons.person,
                              ),
                              Text(
                                "Profile",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                user.UserInfo.routeName,
                                arguments: widget.currentUser);
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            spacing: 10,
                            children: [
                              const Icon(Icons.settings),
                              Text(
                                "Setting",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(QualitySettingsScreen.routeName);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize * 0.0106,
                  vertical: screenSize * 0.0053,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: screenSize * 0.425, //435
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: (state.quickPicks.length / 4)
                            .ceil(), // Calculate the number of horizontal items
                        itemBuilder: (context, rowIndex) {
                          return SongColumView(
                            rowIndex: rowIndex,
                            quickPicksLength: state.quickPicks.length,
                            quickPicks: state.quickPicks,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: screenSize * 0.0106),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            //"Playlists For You",
                            "Recommended playlists",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(ShowAllPlaylists.routeName);
                            },
                            child: Container(
                              color: Colors.transparent,
                              width: screenSize * 0.080,
                              alignment: Alignment.topRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: screenSize * 0.0290,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenSize * 0.350,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: state.playlist.length >= 6
                            ? 6
                            : state.playlist.length,
                        itemBuilder: (context, index) {
                          final playlistData = state.playlist[index];

                          return HomePlaylist(playList: playlistData);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
