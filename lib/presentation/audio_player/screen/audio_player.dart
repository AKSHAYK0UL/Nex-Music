import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/download_bloc/bloc/download_bloc.dart';
import 'package:nex_music/bloc/favorites_bloc/bloc/favorites_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/presentation/audio_player/widget/download_bar.dart';
import 'package:nex_music/presentation/user_playlist/widgets/add_to_playlist_bottom_sheet.dart';
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
                  // GestureDetector(
                  //   onTap: () {
                  //     context.read<SongstreamBloc>().add(PauseEvent());
                  //     Navigator.of(context)
                  //         .pushNamed(SongVideo.routeName, arguments: songData);
                  //   },
                  //   child: Icon(
                  //     Icons.smart_display,
                  //     color: textColor,
                  //     size: screenSize * 0.0330,
                  //   ),
                  // ),
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
                              topRight: Radius.circular(screenSize * 0.0131),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(screenSize * 0.0131),
                                topRight: Radius.circular(screenSize * 0.0131)),
                            child: Transform.scale(
                              scaleX: quality == ThumbnailQuality.low &&
                                      !songData.isLocal
                                  ? 1
                                  : 1.10,
                              child: cacheImage(
                                  imageUrl: songData.thumbnail,
                                  width: screenSize * 0.448,
                                  height: screenSize * 0.410,
                                  islocal: songData.isLocal),
                            ),

                            // child: Transform.scale(
                            //   scaleX: quality == ThumbnailQuality.low &&
                            //           !songData.isLocal
                            //       ? 1
                            //       : 1.78,
                            //   scaleY: 1.0,
                            //   child: cacheImage(
                            //       imageUrl: songData.thumbnail,
                            //       width: screenSize * 0.448,
                            //       height: screenSize * 0.410,
                            //       islocal: songData.isLocal),
                            // ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                //
                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenSize * 0.0328),
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
                        BlocBuilder<DownloadBloc, DownloadState>(
                          builder: (context, state) {
                            return IconButton(
                              onPressed: state is DownloadPercantageStatusState
                                  ? null
                                  : () {
                                      context.read<DownloadBloc>().add(
                                          DownloadSongEvent(
                                              songData: songData));
                                    },
                              icon: Icon(
                                Icons.downloading_sharp,
                                color: state is DownloadPercantageStatusState
                                    ? Colors.grey.shade700
                                    : textColor,
                                size: screenSize * 0.0395,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            // showAddToPlaylistDialog(context, songData);
                            addToPlayListBottomSheet(
                                context, songData, screenSize);
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
                // SizedBox(height: screenSize * 0.0200),
                SizedBox(height: screenSize * 0.0100),

                StreamBuilderWidget(screenSize: screenSize),
                // SizedBox(height: screenSize * 0.0150),
                SizedBox(height: screenSize * 0.0100),

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
            SizedBox(height: screenSize * 0.0300),
            BlocConsumer<DownloadBloc, DownloadState>(
              listenWhen: (previous, current) => previous != current,
              listener: (context, state) {
                if (state is DownloadErrorState) {
                  showSnackbar(context, state.errorMessage);
                }
              },
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                if (state is DownloadCompletedState) {
                  context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
                }
                if (state is DownloadPercantageStatusState) {
                  return StreamBuilder<double>(
                    stream: state.percentageStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: accentColor,
                        );
                      }
                      if (snapshot.hasError) {
                        showSnackbar(context, "Error in Downloading");
                      }
                      return DownloadBar(
                        downloadPercentage: snapshot.data!,
                        songData: state.songData,
                        quality: quality,
                        screenSize: screenSize,
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
