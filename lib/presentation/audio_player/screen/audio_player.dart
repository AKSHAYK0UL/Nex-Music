// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nex_music/bloc/favorites_bloc/bloc/favorites_bloc.dart';
// import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
// import 'package:nex_music/core/theme/hexcolor.dart';
// import 'package:nex_music/core/ui_component/animatedtext.dart';
// import 'package:nex_music/core/ui_component/cacheimage.dart';
// import 'package:nex_music/enum/quality.dart';
// import 'package:nex_music/enum/song_miniplayer_route.dart';
// import 'package:nex_music/model/songmodel.dart';
// import 'package:nex_music/presentation/audio_player/widget/player.dart';
// import 'package:nex_music/presentation/audio_player/widget/streambuilder.dart';
// import 'package:share_plus/share_plus.dart';

// class AudioPlayerScreen extends StatefulWidget {
//   static const routeName = "/audioplayer";
//   const AudioPlayerScreen({super.key});

//   @override
//   State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final routeData =
//           ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
//       Songmodel songData = routeData["songdata"] as Songmodel;
//       context.read<FavoritesBloc>().add(IsFavoritesEvent(vId: songData.vId));
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.sizeOf(context).height;
//     final routeData =
//         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
//     Songmodel songData = routeData["songdata"] as Songmodel;
//     final route = routeData["route"] as SongMiniPlayerRoute;
//     final songIndex = routeData["songindex"] as int;
//     final quality = routeData["quality"] as ThumbnailQuality;
//     print("THUMBNAIL : $quality");

//     return Scaffold(
//       body: SafeArea(
//           child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: screenSize * 0.026, vertical: screenSize * 0.00725),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Icon(
//                     Icons.keyboard_arrow_down,
//                     color: textColor,
//                     size: screenSize * 0.0493,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () async {
//                     await Share.share(
//                         "https://music.youtube.com/watch?v=${songData.vId}");
//                   },
//                   child: Icon(
//                     Icons.share,
//                     color: textColor,
//                     size: screenSize * 0.0330,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
//                 child: BlocBuilder<SongstreamBloc, SongstreamState>(
//                   buildWhen: (previous, current) => previous != current,
//                   builder: (context, state) {
//                     context
//                         .read<FavoritesBloc>()
//                         .add(IsFavoritesEvent(vId: songData.vId));

//                     if (state is LoadingState) {
//                       songData = state.songData;
//                     }
//                     if (state is PlayingState) {
//                       songData = state.songData;
//                     }
//                     if (state is PausedState) {
//                       songData = state.songData;
//                     }
//                     return Center(
//                       child: Container(
//                         height: screenSize * 0.410,
//                         width: screenSize * 0.448,
//                         decoration: BoxDecoration(
//                           borderRadius:
//                               BorderRadius.circular(screenSize * 0.0131),
//                         ),
//                         child: ClipRRect(
//                           borderRadius:
//                               BorderRadius.circular(screenSize * 0.0131),
//                           child: Transform.scale(
//                             scaleX: quality == ThumbnailQuality.low ? 1 : 1.78,
//                             scaleY: 1.0,
//                             child: cacheImage(
//                               imageUrl: songData.thumbnail,
//                               width: screenSize * 0.448,
//                               height: screenSize * 0.410,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               SizedBox(
//                 height: screenSize * 0.0380,
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: screenSize * 0.356,
//                           child: BlocBuilder<SongstreamBloc, SongstreamState>(
//                             buildWhen: (previous, current) =>
//                                 previous != current,
//                             builder: (context, state) {
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   animatedText(
//                                     text: songData.songName,
//                                     style:
//                                         Theme.of(context).textTheme.titleLarge!,
//                                   ),
//                                   SizedBox(
//                                     height: screenSize * 0.0050,
//                                   ),
//                                   animatedText(
//                                     text: songData.artist.name,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleMedium!,
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     BlocBuilder<FavoritesBloc, FavoritesState>(
//                       buildWhen: (previous, current) => previous != current,
//                       builder: (context, state) {
//                         bool isFavorite = false;
//                         if (state is IsFavoritesState) {
//                           isFavorite = state.isFavorites;
//                         }

//                         return IconButton(
//                           onPressed: () {
//                             if (isFavorite) {
//                               context.read<FavoritesBloc>().add(
//                                   RemoveFromFavoritesEvent(vId: songData.vId));
//                             } else {
//                               context
//                                   .read<FavoritesBloc>()
//                                   .add(AddToFavoritesEvent(song: songData));
//                             }
//                           },
//                           icon: Icon(
//                             isFavorite
//                                 ? CupertinoIcons.heart_fill
//                                 : CupertinoIcons.heart,
//                             color: textColor,
//                             size: screenSize * 0.0395,
//                           ),
//                         );
//                       },
//                     ),
//                     // IconButton(onPressed: onPressed, icon: icon)
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: screenSize * 0.0400,
//               ),
//               StreamBuilderWidget(
//                 screenSize: screenSize,
//               ),
//               SizedBox(
//                 height: screenSize * 0.0150,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   BlocBuilder<SongstreamBloc, SongstreamState>(
//                     buildWhen: (previous, current) => previous != current,
//                     builder: (context, state) {
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               context.read<SongstreamBloc>().add(MuteEvent());
//                             },
//                             icon: Icon(
//                               context.read<SongstreamBloc>().getMuteStatus
//                                   ? Icons.volume_off
//                                   : Icons.volume_up,
//                               color: textColor,
//                               size: screenSize * 0.0400, //329
//                             ),
//                           ),
//                           SizedBox(
//                             width: screenSize * 0.0197,
//                           ),
//                           IconButton(
//                             onPressed: () {
//                               context
//                                   .read<SongstreamBloc>()
//                                   .add(PlayPreviousSongEvent());
//                             },
//                             icon: Icon(
//                               Icons.skip_previous,
//                               color: textColor,
//                               size: screenSize * 0.0527,
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                   SizedBox(
//                     width: screenSize * 0.0131,
//                   ),
//                   Player(
//                     songData: songData,
//                     songIndex: songIndex,
//                     screenSize: screenSize,
//                     route: route,
//                   ),
//                   SizedBox(
//                     width: screenSize * 0.0131,
//                   ),
//                   BlocBuilder<SongstreamBloc, SongstreamState>(
//                     buildWhen: (previous, current) => previous != current,
//                     builder: (context, state) {
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               context
//                                   .read<SongstreamBloc>()
//                                   .add(PlayNextSongEvent());
//                             },
//                             icon: Icon(
//                               Icons.skip_next,
//                               color: textColor,
//                               size: screenSize * 0.0527,
//                             ),
//                           ),
//                           SizedBox(
//                             width: screenSize * 0.0197,
//                           ),
//                           IconButton(
//                             onPressed: () {
//                               context.read<SongstreamBloc>().add(LoopEvent());
//                             },
//                             icon: Icon(
//                               context.read<SongstreamBloc>().getLoopStatus
//                                   ? Icons.loop_outlined
//                                   : Icons.shuffle_outlined,
//                               color: textColor,
//                               size: screenSize * 0.0400,
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: screenSize * 0.0240,
//               ),
//               Align(
//                 alignment: Alignment.center,
//                 child: IconButton(
//                   onPressed: () {
//                     //for test only
//                     // showModalBottomSheet(
//                     //     context: context,
//                     //     builder: (context) {
//                     //       return Container(
//                     //           height: 400,
//                     //           width: double.infinity,
//                     //           color: Colors.black,
//                     //           child: Column(
//                     //             children: [
//                     //               Text("View Artist"),
//                     //               Text("Add to Playlist"),
//                     //               Text("Download")
//                     //             ],
//                     //           ));
//                     //     });

//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       backgroundColor: Colors
//                           .transparent, // Optional, to make it look modern
//                       builder: (context) {
//                         return DraggableScrollableSheet(
//                           initialChildSize: 0.2,
//                           minChildSize: 0.1,
//                           maxChildSize: 0.2,
//                           builder: (_, controller) {
//                             return Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.vertical(
//                                     top: Radius.circular(20)),
//                               ),
//                               child: ListView(
//                                 controller: controller,
//                                 padding: EdgeInsets.all(16),
//                                 children: [
//                                   Center(
//                                     child: Container(
//                                       width: 40,
//                                       height: 4,
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey[700],
//                                         borderRadius: BorderRadius.circular(2),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   const Text("View Artist",
//                                       style: TextStyle(color: Colors.white)),
//                                   const SizedBox(height: 12),
//                                   const Text("Add to Playlist",
//                                       style: TextStyle(color: Colors.white)),
//                                   const SizedBox(height: 12),
//                                   const Text("Download",
//                                       style: TextStyle(color: Colors.white)),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                   icon: Icon(
//                     Icons.keyboard_arrow_up,
//                     color: textColor,
//                     size: screenSize * 0.0593,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ],
//       )),
//     );
//   }
// }

//==============================================================================

// =============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/favorites_bloc/bloc/favorites_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/presentation/user_playlist/widgets/add_to_playlist_dialog.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/player.dart';
import 'package:nex_music/presentation/audio_player/widget/streambuilder.dart';
import 'package:share_plus/share_plus.dart';

class AudioPlayerScreen extends StatefulWidget {
  static const routeName = "/audioplayer";
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  void initState() {
    context.read<UserPlaylistBloc>().add(GetUserPlaylistsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeData =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      Songmodel songData = routeData["songdata"] as Songmodel;
      context.read<FavoritesBloc>().add(IsFavoritesEvent(vId: songData.vId));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD @@ AUDIO SCREEN");

    final screenSize = MediaQuery.sizeOf(context).height;
    final routeData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    Songmodel songData = routeData["songdata"] as Songmodel;
    final route = routeData["route"] as SongMiniPlayerRoute;
    final songIndex = routeData["songindex"] as int;
    final quality = routeData["quality"] as ThumbnailQuality;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenSize * 0.026,
                  vertical: screenSize * 0.00725),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: textColor,
                      size: screenSize * 0.0493,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Share.share(
                          "https://music.youtube.com/watch?v=${songData.vId}");
                    },
                    child: Icon(
                      Icons.share,
                      color: textColor,
                      size: screenSize * 0.0330,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
                  child: BlocBuilder<SongstreamBloc, SongstreamState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      context
                          .read<FavoritesBloc>()
                          .add(IsFavoritesEvent(vId: songData.vId));
                      if (state is LoadingState ||
                          state is PlayingState ||
                          state is PausedState) {
                        songData = (state as dynamic).songData;
                      }
                      return Center(
                        child: Container(
                          height: screenSize * 0.410,
                          width: screenSize * 0.448,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(screenSize * 0.0131),
                                topRight: Radius.circular(screenSize * 0.0131)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(screenSize * 0.0131),
                                topRight: Radius.circular(screenSize * 0.0131)),
                            child: Transform.scale(
                              scaleX:
                                  quality == ThumbnailQuality.low ? 1 : 1.78,
                              scaleY: 1.0,
                              child: cacheImage(
                                imageUrl: songData.thumbnail,
                                width: screenSize * 0.448,
                                height: screenSize * 0.410,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                //
                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenSize * 0.0331),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(screenSize * 0.0131),
                        bottomRight: Radius.circular(screenSize * 0.0131)),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.person,
                            color: textColor,
                            size: screenSize * 0.0395,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.download,
                            color: textColor,
                            size: screenSize * 0.0395,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showAddToPlaylistDialog(context, songData);
                          },
                          icon: Icon(
                            Icons.playlist_add,
                            color: textColor,
                            size: screenSize * 0.0395,
                          ),
                        ),
                      ]),
                ),
                //
                // SizedBox(height: screenSize * 0.0380),
                SizedBox(height: screenSize * 0.0080),

                Padding(
                  padding: EdgeInsets.only(left: screenSize * 0.0229),
                  //
                  child: ListTile(
                    minVerticalPadding: 5,
                    tileColor: backgroundColor,
                    title: BlocBuilder<SongstreamBloc, SongstreamState>(
                      buildWhen: (previous, current) => previous != current,
                      builder: (context, state) {
                        return animatedText(
                          text: songData.songName,
                          style: Theme.of(context).textTheme.titleLarge!,
                        );
                      },
                    ),
                    subtitle: BlocBuilder<SongstreamBloc, SongstreamState>(
                      buildWhen: (previous, current) => previous != current,
                      builder: (context, state) {
                        return animatedText(
                          text: songData.artist.name,
                          style: Theme.of(context).textTheme.titleMedium!,
                        );
                      },
                    ),
                    trailing: BlocBuilder<FavoritesBloc, FavoritesState>(
                      buildWhen: (previous, current) => previous != current,
                      builder: (context, state) {
                        bool isFavorite = false;
                        if (state is IsFavoritesState) {
                          isFavorite = state.isFavorites;
                        }
                        return IconButton(
                          onPressed: () {
                            if (isFavorite) {
                              context.read<FavoritesBloc>().add(
                                  RemoveFromFavoritesEvent(vId: songData.vId));
                            } else {
                              context
                                  .read<FavoritesBloc>()
                                  .add(AddToFavoritesEvent(song: songData));
                            }
                          },
                          icon: Icon(
                            isFavorite
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: textColor,
                            size: screenSize * 0.0395,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // SizedBox(height: screenSize * 0.0400),
                SizedBox(height: screenSize * 0.0200),

                StreamBuilderWidget(screenSize: screenSize),
                SizedBox(height: screenSize * 0.0150),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocBuilder<SongstreamBloc, SongstreamState>(
                      buildWhen: (previous, current) => previous != current,
                      builder: (context, state) {
                        return Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                context.read<SongstreamBloc>().add(MuteEvent());
                              },
                              icon: Icon(
                                context.read<SongstreamBloc>().getMuteStatus
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: textColor,
                                size: screenSize * 0.0400,
                              ),
                            ),
                            SizedBox(width: screenSize * 0.0197),
                            IconButton(
                              onPressed: () {
                                context
                                    .read<SongstreamBloc>()
                                    .add(PlayPreviousSongEvent());
                              },
                              icon: Icon(
                                Icons.skip_previous,
                                color: textColor,
                                size: screenSize * 0.0527,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(width: screenSize * 0.0131),
                    Player(
                      songData: songData,
                      songIndex: songIndex,
                      screenSize: screenSize,
                      route: route,
                    ),
                    SizedBox(width: screenSize * 0.0131),
                    BlocBuilder<SongstreamBloc, SongstreamState>(
                      buildWhen: (previous, current) => previous != current,
                      builder: (context, state) {
                        return Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                context
                                    .read<SongstreamBloc>()
                                    .add(PlayNextSongEvent());
                              },
                              icon: Icon(
                                Icons.skip_next,
                                color: textColor,
                                size: screenSize * 0.0527,
                              ),
                            ),
                            SizedBox(width: screenSize * 0.0197),
                            IconButton(
                              onPressed: () {
                                context.read<SongstreamBloc>().add(LoopEvent());
                              },
                              icon: Icon(
                                context.read<SongstreamBloc>().getLoopStatus
                                    ? Icons.loop_outlined
                                    : Icons.shuffle_outlined,
                                color: textColor,
                                size: screenSize * 0.0400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
